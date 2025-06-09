//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation
import Rest

public class LemmyConnection: InstanceConnection {
    private let restClient = RestClient<ApiErrorResponse>()
    
    enum LemmyConnectionError: Error {
        case invalidSession
    }
    
    public let baseUrl: URL
    public var token: String?
    
    init(baseUrl: URL, token: String? = nil) {
        self.baseUrl = baseUrl
        self.token = token
    }

    public func updateToken(_ newToken: String) {
        token = newToken
    }

    @discardableResult
    func perform<Request: RestRequest>(
        _ request: Request,
        tokenOverride: String? = nil
    ) async throws -> Request.Response {
        let token = tokenOverride ?? token
        do throws(RestError) {
            return try await restClient.perform(baseUrl: baseUrl, request, token: token)
        } catch {
            switch error {
            case let RestError.response(response, statusCode: _):
                if ApiErrorResponse(error: response).isNotLoggedIn {
                    if token == nil {
                        throw ApiClientError.notLoggedIn
                    } else {
                        throw LemmyConnectionError.invalidSession
                    }
                } else {
                    throw ApiClientError(from: error)
                }
            default:
                throw ApiClientError(from: error)
            }
        }
    }
    
    // When this function is called, the `requestGenerator` will be called at least once,
    // but may be called more than once.
    func performingForEndpoint<Request: RestRequest>(
        _ requestGenerator: (SiteVersion.EndpointVersion) async throws -> Request
    ) async throws -> Request.Response {
        // This is placeholder code - in future this will be updated to sometimes use .v4
        try await perform(requestGenerator(.v3))
    }
    
    // When this function is called, the `callback` will be called at least once,
    // but may be called more than once.
    func processingForEndpoint<Response>(
        _ callback: (SiteVersion.EndpointVersion) async throws -> Response
    ) async throws -> Response {
        // This is placeholder code - in future this will be updated to sometimes use .v4
        try await callback(.v3)
    }
}
