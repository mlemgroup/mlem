//
//  ApiClient.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Combine
import Foundation
import SwiftyJSON

@Observable
public class ApiClient {
    public enum RequestPermissions {
        case all, getOnly, none
    }
    
    let decoder: JSONDecoder = .defaultDecoder
    let urlSession: URLSession = .init(configuration: .default)
    
    // url and username MAY NOT be modified! Downstream code expects that a given ApiClient will *always* submit requests from the same user to the same instance.
    public let baseUrl: URL
    public let username: String?
    
    public internal(set) var token: String?
    
    public private(set) var contextDataManager: SharedTaskManager<Context> = .init()
    
    /// When `true`, the token will not be attatched to any API requests. This is useful for ensuring that inactive accounts don't accidentally make requests
    public var permissions: RequestPermissions = .all
    
    public var willSendToken: Bool { permissions == .all && token != nil }
    
    public internal(set) weak var myInstance: Instance3?
    public internal(set) weak var myPerson: Person4?
    public internal(set) weak var subscriptions: SubscriptionList?
    public internal(set) weak var blocks: BlockList?
    public internal(set) weak var unreadCount: UnreadCount?
    
    /// Stores the IDs of posts that are queued to be marked read.
    internal var markReadQueue: MarkReadQueue = .init()
    
    public var fetchedVersion: SiteVersion? {
        contextDataManager.fetchedValue?.siteVersion
    }
    
    /// Returns the `fetchedVersion` if the version has already been fetched. Otherwise, waits until the version has been fetched before returning the received value.
    public var version: SiteVersion {
        get async throws {
            try await contextDataManager.getValue().siteVersion
        }
    }
    
    public var myPersonId: Int? {
        get async throws {
            try await contextDataManager.getValue().myPersonId
        }
    }
    
    public func ensureContextPresence() async throws {
        try await contextDataManager.getValue()
    }
    
    /// Returns whether the version supports the given feature
    public func supports(_ feature: SiteVersion.Feature) async throws -> Bool {
        try await version.suppports(feature)
    }
    
    /// Returns whether the fetched version supports the given feature. Defaults to false if no fetched version available.
    public func fetchedVersionSupports(_ feature: SiteVersion.Feature) -> Bool {
        return fetchedVersion?.suppports(feature) ?? false
    }
    
    // MARK: caching
    
    /// Caches of objects stored per ApiClient instance
    /// - Warning: DO NOT access this outside of ApiClient!
    var caches: BaseCacheGroup = .init()
    
    /// Caches of Instance objects, shared across all ApiClient instances
    /// - Warning: DO NOT access this outside of ApiClient!
    static var apiClientCache: ApiClientCache = .init()
    
    /// Creates or retrieves an API client for the given connection parameters
    public static func getApiClient(url: URL, username: String?) -> ApiClient {
        apiClientCache.createOrRetrieveApiClient(url: url, username: username)
    }
    
    /// This should never be used outside of ApiClientCache (and MockApiClient), as the caching system depends on one ApiClient existing for any given session.
    internal init(
        url: URL,
        username: String? = nil,
        permissions: RequestPermissions = .all
    ) {
        self.baseUrl = url
        self.username = username
        self.permissions = permissions
        contextDataManager.fetchTask = {
            let (person, instance, _) = try await self.getMyPerson()
            return .init(instance: instance, person: person)
        }
    }
    
    public func cleanCaches() {
        caches.clean()
        ApiClient.apiClientCache.clean()
    }
    
    /// Return a new guest `ApiClient`.
    public func asGuest() -> ApiClient {
        .getApiClient(url: self.baseUrl, username: nil)
    }
    
    /// Return a new `ApiClient` targeting the given user.
    public func asUser(name: String) -> ApiClient {
        .getApiClient(url: self.baseUrl, username: name)
    }
    
    /// This should **only** be used when we get a new token for **the same** account!
    public func updateToken(_ newToken: String) {
        guard username != nil else {
            assertionFailure()
            return
        }
        self.token = newToken
    }
    
    @discardableResult
    func perform<Request: ApiRequest>(
        _ request: Request,
        tokenOverride: String? = nil,
        requiresToken: Bool = true // This should be `true` for the vast majority of requests, even GET requests
    ) async throws -> Request.Response {
        let token = tokenOverride ?? self.token
        
        guard !requiresToken || self.username == nil || token != nil else {
            throw ApiClientError.noToken
        }
        
        let urlRequest = try urlRequest(from: request, tokenOverride: tokenOverride)
        // this line intentionally left commented for convenient future debugging
        // urlRequest.debug()
        let (data, response) = try await execute(urlRequest, tokenOverride: tokenOverride)
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
                throw token == nil ? ApiClientError.notLoggedIn : ApiClientError.invalidSession(self)
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            throw ApiClientError.response(apiError, statusCode)
        }
        
        return try decode(Request.Response.self, from: data)
    }
    
    internal func execute(
        _ urlRequest: URLRequest,
        tokenOverride: String? = nil
    ) async throws -> (Data, URLResponse) {
        var urlRequest: URLRequest = urlRequest // make mutable
        let token = tokenOverride ?? self.token
        
        if urlRequest.httpMethod != "GET", // GET requests do not support body
           !fetchedVersionSupports(.headerAuthentication),
           let token { // only add if we have a token
            let authBody: JSON = .init(dictionaryLiteral: ("auth", token))
            let newBody: JSON
            if let httpBody = urlRequest.httpBody {
                newBody = try JSON(httpBody).merged(with: authBody)
            } else {
                newBody = authBody
            }
            
            urlRequest.httpBody = try newBody.rawData()
        }
        
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
    
    func urlRequest(
        from definition: any ApiRequest,
        tokenOverride: String? = nil
    ) throws -> URLRequest {
        let token = tokenOverride ?? self.token
        guard permissions != .none else { throw ApiClientError.insufficientPermissions }
        let url = try definition.endpoint(base: baseUrl)
        var urlRequest = mlemUrlRequest(url: url)
        for header in definition.headers {
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
        } else if let deleteDefinition = definition as? any ApiDeleteRequest {
            urlRequest.httpMethod = "DELETE"
            urlRequest.httpBody = try createBodyData(for: deleteDefinition)
        }
        
        if let token, permissions == .all {
            // TODO: 0.18 deprecation remove this
            urlRequest.url?.append(queryItems: [.init(name: "auth", value: token)])
            
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
    
    func createBodyData(for defintion: any ApiRequestBodyProviding) throws -> Data {
        do {
            let encoder = JSONEncoder()
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

extension ApiClient: CacheIdentifiable {
    public var cacheId: Int {
        ApiClient.apiClientCache.getCacheId(url: baseUrl, username: username)
    }
}

extension ApiClient: ActorIdentifiable {
    public var actorId: ActorIdentifier { .instance(host: baseUrl.host()!) }
}

extension ApiClient: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.baseUrl)
        hasher.combine(self.username)
    }
    
    public static func == (lhs: ApiClient, rhs: ApiClient) -> Bool {
        lhs === rhs
    }
}

extension ApiClient: CustomDebugStringConvertible {
    public var debugDescription: String {
        "ApiClient(\(host), authenticated: \(token != nil))"
    }
}

extension ApiClient {
    public struct Context {
        let siteVersion: SiteVersion
        let myPersonId: Int?
    }
}

extension ApiClient.Context {
    public init(instance: Instance3, person: Person4?) {
        self.siteVersion = instance.version
        self.myPersonId = person?.id
    }
}

// MARK: ApiClientCache

// This needs to be declared in this file to have access to the private initializer

extension ApiClient {
    /// Cache for ApiClient--exception case because there's no ApiType and it may need to perform ApiClient bootstrapping
    class ApiClientCache: CoreCache<ApiClient> {
        func getCacheId(url: URL, username: String?) -> Int {
            var hasher: Hasher = .init()
            hasher.combine(url.removingPathComponents().appendingPathComponent("/"))
            hasher.combine(username)
            return hasher.finalize()
        }
        func createOrRetrieveApiClient(url: URL, username: String?) -> ApiClient {
            let url = url.removingPathComponents().appendingPathComponent("/")
            if let client = retrieveModel(cacheId: getCacheId(url: url, username: username)) {
                return client
            }
            
            let ret: ApiClient = .init(url: url, username: username)
            itemCache.put(ret)
            return ret
        }
    }
}
