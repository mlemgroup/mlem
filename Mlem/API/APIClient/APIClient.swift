//
//  UnauthenticatedApiClient.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Combine
import Foundation
import SwiftUI

@Observable
class ApiClient {
    let decoder: JSONDecoder = .defaultDecoder
    let urlSession: URLSession = .init(configuration: .default)
    
    let baseUrl: URL
    let endpointUrl: URL
    var token: String?
    
    init(baseUrl: URL, token: String? = nil) {
        self.baseUrl = baseUrl
        self.endpointUrl = baseUrl.appendingPathComponent("api/v3")
        self.token = token
    }
    
    @discardableResult
    func perform<Request: ApiRequest>(request: Request) async throws -> Request.Response {
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

        if let token {
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
            let data = try encoder.encode(body)
            
            // TODO: 0.18 deprecation remove all of the following logic and simply return the `data` above
            if let token {
                let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                guard var dictionary else { throw ApiClientError.failedToWriteTokenToBody }
                dictionary["auth"] = token
                return try JSONSerialization.data(withJSONObject: dictionary, options: [])
            } else {
                return data
            }
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
