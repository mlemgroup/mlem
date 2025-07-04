//
//  ApiRepository.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-02.
//

import Rest
import Foundation

/// This class represents an abstract interface on top of the underlying Connection; it is responsible for managing the Connection and
/// serving consistent Snapshot models to higher layers.
///
/// The data access methods in here are all intentionally dumb--they just make calls and return snapshots. Validation, enrichment,
/// and other business logic that must occur before serving the final model to the app should be performed by the consumer of the repository.
internal class ApiRepository {
    private static let supportedConnections: [any InstanceConnection.Type] = [LemmyConnection.self, PieFedConnection.self]
    
    let baseUrl: URL
    let username: String?
    
    private var ongoingConnectionDiscoveryTask: Task<Any, Error>?
    var connection: (any InstanceConnection)?
    
    var restClient: RestClient<ApiErrorResponse> = .init()
    
    var token: String?
    
    init(baseUrl: URL, username: String? = nil) {
        self.baseUrl = baseUrl
        self.username = username
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
        _ = await ongoingConnectionDiscoveryTask?.result
        if let connection {
            return connection
        }
        _ = try await getMyInstance()
        if let connection {
            return connection
        }
        assertionFailure()
        throw ApiClientError.unsuccessful
    }
    
    @MainActor
    func performingForConnection<T>(
        _ callback: @escaping (any InstanceConnection) async throws -> T,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) async throws -> T {
        // Iterate through all possible connections, and attempt the request on all of them in parallel.
        // As soon as one of the requests succeeds, return the result and cancel the other ongoing requests.
        // Cache the `InstanceConnection` that succeeded in the `self.connection` property, and use that
        // for all subsequent calls of `performingForConnection`.
        
        // If `performingForConnection` is called and `self.connection` is `nil` but there is another
        // `performingForConnection` call ongoing, it will wait for the other call to succeed first.

        _ = await self.ongoingConnectionDiscoveryTask?.result
        if let connection {
            return try await callback(connection)
        }

        let ongoingConnectionDiscoveryTask: Task<T, Error> = Task {
            try await withThrowingTaskGroup(of: (any InstanceConnection, Result<T, Error>).self) { group in
                for connectionType in Self.supportedConnections {
                    let connection = connectionType.init(baseUrl: baseUrl, token: token)
                    group.addTask {
                        do {
                            let response = try await callback(connection)
                            return (connection, .success(response))
                        } catch {
                            return (connection, .failure(error))
                        }
                    }
                }
                
                while !group.isEmpty {
                    guard let result = try? await group.next() else {
                        assertionFailure()
                        continue
                    }
                    do {
                        let value = try result.1.get()
                        // Cancel all other tasks once any one task succeeds
                        group.cancelAll()
                        self.connection = result.0
                        self.ongoingConnectionDiscoveryTask = nil
                        return value
                    } catch ApiClientError.serverError(404), ApiClientError.featureUnsupported {
                        // no-op
                    } catch {
                        // We *could* set the `connection` here, but I'd rather not just incase some other
                        // 404-equivalent error is thrown that we haven't accounted for
                        throw error
                    }
                }
                
                throw ApiClientError.unableToDetermineSoftware
            }
        }
        
        self.ongoingConnectionDiscoveryTask = Task {
            _ = try? await ongoingConnectionDiscoveryTask.result.get()
        }
        
        return try await ongoingConnectionDiscoveryTask.result.get()
    }
}
