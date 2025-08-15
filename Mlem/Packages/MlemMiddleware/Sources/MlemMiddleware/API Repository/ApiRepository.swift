//
//  ApiRepository.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-02.
//

import Foundation
import Rest

/// This class represents an abstract interface on top of the underlying Connection; it is responsible for managing the Connection and
/// serving consistent Snapshot models to higher layers.
///
/// The data access methods in here are all intentionally dumb--they just make calls and return snapshots. Validation, enrichment,
/// and other business logic that must occur before serving the final model to the app should be performed by the consumer of the repository.
class ApiRepository {
    private static let supportedConnections: [any InstanceConnection.Type] = [LemmyConnection.self, PieFedConnection.self]
    
    private struct ConnectionWrapper {
        let wrappedValue: any InstanceConnection
    }
    
    let baseUrl: URL
    let username: String?
    private var connectionMultiplexer: ConnectionMultiplexer<ConnectionWrapper>!
    
    var restClient: RestClient<ApiErrorResponse> = .init()
    var token: String?
    
    var connection: (any InstanceConnection)? {
        get {
            connectionMultiplexer.selectedCandidate?.wrappedValue
        }
        set {
            connectionMultiplexer.selectedCandidate = .init(wrappedValue: newValue!)
        }
    }

    init(baseUrl: URL, username: String? = nil) {
        self.baseUrl = baseUrl
        self.username = username
        
        self.connectionMultiplexer = .init {
            Self.supportedConnections.map { .init(wrappedValue: $0.init(baseUrl: self.baseUrl, token: self.token)) }
        }
    }
    
    func updateToken(_ newToken: String) {
        guard username != nil else {
            assertionFailure()
            return
        }
        
        connection?.updateToken(newToken)
        token = newToken
    }
    
    func perform<Request: RestRequest>(
        _ request: Request,
        tokenOverride: String? = nil,
        requiresToken: Bool = true // This should be `true` for the vast majority of requests, even GET requests
    ) async throws -> Request.Response {
        guard !requiresToken || username == nil || token != nil else {
            throw ApiClientError.noToken
        }
        
        let token = tokenOverride ?? token
        do throws(RestError) {
            return try await restClient.perform(baseUrl: baseUrl, request, token: token)
        } catch {
            switch error {
            case let RestError.response(response, statusCode: _):
                if ApiErrorResponse(error: response).isNotLoggedIn {
                    throw token == nil ? ApiClientError.notLoggedIn : ApiClientError.invalidSession // (self)
                } else {
                    throw ApiClientError(from: error)
                }
            default:
                throw ApiClientError(from: error)
            }
        }
    }
    
    func getConnection() async throws -> any InstanceConnection {
        try await connectionMultiplexer.getConnection {
            _ = try await getMyInstance()
        }.wrappedValue
    }
    
    @MainActor
    func performingForConnection<T>(
        _ callback: @escaping (any InstanceConnection) async throws -> T,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) async throws -> T {
        do {
            return try await connectionMultiplexer.perform { wrapper in
                try await callback(wrapper.wrappedValue)
            }
        } catch ConnectionMultiplexerError.allConnectionsFailed {
            throw ApiClientError.unableToDetermineSoftware
        }
    }
}
