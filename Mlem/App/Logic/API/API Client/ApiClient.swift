//
//  ApiClient.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Combine
import Foundation

class ApiClient: ActorIdentifiable, CacheIdentifiable {
    let decoder: JSONDecoder = .defaultDecoder
    let urlSession: URLSession = .init(configuration: .default)
    
    // url and token MAY NOT be modified! Downstream code expects that a given ApiClient will *always* submit requests from the same user to the same instance.
    let baseUrl: URL
    let endpointUrl: URL
    let token: String?
    var version: SiteVersion?
    
    /// When `true`, the token will not be attatched to any API requests. This is useful for ensuring that inactive accounts don't accidentally make requests
    var locked: Bool = false
    
    var willSendToken: Bool { !(locked || token == nil) }
    
    // CacheIdentifiable, ActorIdentifiable conformance
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(baseUrl)
        hasher.combine(token)
        return hasher.finalize()
    }

    var actorId: URL { baseUrl }
    
    // MARK: caching
    
    /// Caches of objects stored per ApiClient instance
    /// - Warning: DO NOT access this outside of ApiClient!
    var caches: BaseCacheGroup = .init()
    
    /// Caches of Instance objects, shared across all ApiClient instances
    /// - Warning: DO NOT access this outside of ApiClient!
    static var apiClientCache: ApiClientCache = .init()

    func cleanCaches() {
        caches.clean()
        ApiClient.apiClientCache.clean()
    }
    
    /// Creates or retrieves an API client for the given connection parameters
    static func getApiClient(for url: URL, with token: String?) -> ApiClient {
        apiClientCache.createOrRetrieveApiClient(for: url, with: token)
    }
    
    /// Creates a new API Client. Private because it should never be used outside of ApiClientCache, as the caching system depends on one ApiClient existing for any given session
    private init(baseUrl: URL, token: String? = nil) {
        self.baseUrl = baseUrl
        self.endpointUrl = baseUrl.appendingPathComponent("api/v3")
        self.token = token
        
        Task {
            do {
                self.version = try await .init(getSite().version)
            } catch {
                print("Failed to resolve version! \(error)")
            }
        }
    }
    
    @discardableResult
    func perform<Request: ApiRequest>(_ request: Request) async throws -> Request.Response {
        let urlRequest = try urlRequest(from: request)

        let (data, response) = try await execute(urlRequest)
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode >= 500 { // Error code for server being offline.
                throw ApiClientError.response(
                    ApiErrorResponse(error: "Instance appears to be offline.\nTry again later."),
                    response.statusCode
                )
            }
        }
        
        if let apiError = try? decoder.decode(ApiErrorResponse.self, from: data) {
            // at present we have a single error model which appears to be used throughout
            // the API, however we may way to consider adding the error model type as an
            // associated value in the same was as the response to allow requests to define
            // their own error models when necessary, or drop back to this as the default...
            
            if apiError.isNotLoggedIn {
                throw ApiClientError.invalidSession
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw ApiClientError.response(apiError, statusCode)
        }
        
        return try decode(Request.Response.self, from: data)
    }
    
    private func execute(_ urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await urlSession.data(for: urlRequest)
        } catch {
            if case URLError.cancelled = error as NSError {
                throw ApiClientError.cancelled
            } else {
                throw ApiClientError.networking(error)
            }
        }
    }

    func urlRequest(from definition: any ApiRequest) throws -> URLRequest {
        let url = definition.endpoint(base: endpointUrl)
        var urlRequest = URLRequest(url: url)
        definition.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if definition as? any ApiGetRequest != nil {
            urlRequest.httpMethod = "GET"
        } else if let postDefinition = definition as? any ApiPostRequest {
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = try createBodyData(for: postDefinition)
        } else if let putDefinition = definition as? any ApiPutRequest {
            urlRequest.httpMethod = "PUT"
            urlRequest.httpBody = try createBodyData(for: putDefinition)
        }

        if let token, !locked {
            // TODO: 0.18 deprecation remove this
            urlRequest.url?.append(queryItems: [.init(name: "auth", value: token)])
            
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
    
    func createBodyData(for defintion: any ApiRequestBodyProviding) throws -> Data {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let body = defintion.body ?? ""
            return try encoder.encode(body)
        } catch {
            throw ApiClientError.encoding(error)
        }
    }
    
    private func decode<T: Decodable>(_ model: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(model, from: data)
        } catch {
            throw ApiClientError.decoding(data, error)
        }
    }
}

// MARK: ApiClientCache

// This needs to be declared in this file to have access to the private initializer

extension ApiClient {
    /// Cache for ApiClient--exception case because there's no ApiType and it may need to perform ApiClient bootstrapping
    class ApiClientCache: CoreCache<ApiClient> {
        func createOrRetrieveApiClient(for baseUrl: URL, with token: String?) -> ApiClient {
            let cacheId: Int = {
                var hasher: Hasher = .init()
                hasher.combine(baseUrl)
                hasher.combine(token)
                return hasher.finalize()
            }()
            
            if let client = retrieveModel(cacheId: cacheId) {
                return client
            }
            
            let ret: ApiClient = .init(baseUrl: baseUrl, token: token)
            cachedItems[ret.cacheId] = .init(content: ret)
            return ret
        }
    }
}
