//
//  ApiClient.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Combine
import Foundation
import Rest

@Observable
public class ApiClient {
    private static let supportedConnections: [any InstanceConnection.Type] = [LemmyConnection.self, PieFedConnection.self]
    
    // url and username MAY NOT be modified! Downstream code expects that a given ApiClient will *always* submit requests from the same user to the same instance.
    public let baseUrl: URL
    public let username: String?
    
    private var ongoingConnectionDiscoveryTask: Task<Any, Error>?
    var connection: (any InstanceConnection)?
    
    var restClient: RestClient<ApiErrorResponse> = .init()

    public internal(set) var token: String?
    
    public var willSendToken: Bool { token != nil }
    
    public internal(set) weak var myInstance: Instance3?
    public internal(set) weak var myPerson: Person4?
    public internal(set) weak var subscriptions: SubscriptionList?
    public internal(set) weak var blocks: BlockList?
    public internal(set) weak var unreadCount: UnreadCount?
    
    /// Stores the IDs of posts that are queued to be marked read.
    var markReadQueue: MarkReadQueue = .init()
    
    public func ensureContextPresence() async throws {
        try await getConnection().ensureContextPresence()
    }
    
    public func supports(_ feature: Feature) async throws -> Bool {
        try await getConnection().supports(feature)
    }
    
    public func supportsOrNil(_ feature: Feature) -> Bool? {
        connection?.supportsOrNil(feature)
    }
    
    public var contextIsFetched: Bool {
        connection?.contextIsFetched ?? false
    }

    public var myPersonId: Int? {
        get async throws {
            try await getConnection().myPersonId
        }
    }
    
    public var software: SiteSoftware {
        get async throws {
            try await .init(type: .lemmy, version: getConnection().version)
        }
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
    init(
        url: URL,
        username: String? = nil
    ) {
        self.baseUrl = url
        self.username = username
    }
    
    public func cleanCaches() {
        caches.clean()
        ApiClient.apiClientCache.clean()
    }
    
    /// Return a new guest `ApiClient`.
    public func asGuest() -> ApiClient {
        .getApiClient(url: baseUrl, username: nil)
    }
    
    /// Return a new `ApiClient` targeting the given user.
    public func asUser(name: String) -> ApiClient {
        .getApiClient(url: baseUrl, username: name)
    }
    
    /// This should **only** be used when we get a new token for **the same** account!
    public func updateToken(_ newToken: String) {
        guard username != nil else {
            assertionFailure()
            return
        }
        connection?.updateToken(newToken)
        token = newToken
    }
    
    @discardableResult
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
                    throw token == nil ? ApiClientError.notLoggedIn : ApiClientError.invalidSession(self)
                } else {
                    throw ApiClientError(from: error)
                }
            default:
                throw ApiClientError(from: error)
            }
        }
    }
    
    private func getConnection() async throws -> any InstanceConnection {
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
            try await withThrowingTaskGroup(of: (any InstanceConnection, T).self) { group in
                var errors: [any Error] = []
                
                for connectionType in Self.supportedConnections {
                    let connection = connectionType.init(baseUrl: baseUrl, token: token)
                    group.addTask {
                        try await (connection, callback(connection))
                    }
                }
                
                while !group.isEmpty {
                    do {
                        guard let result = try await group.next() else {
                            assertionFailure()
                            continue
                        }
                        // Cancel all other tasks once any one task succeeds
                        group.cancelAll()
                        self.connection = result.0
                        self.ongoingConnectionDiscoveryTask = nil
                        return result.1
                    } catch {
                        errors.append(error)
                    }
                }
                
                throw ApiClientError.unableToDetermineSoftware(errors)
            }
        }
        
        self.ongoingConnectionDiscoveryTask = Task {
            _ = try? await ongoingConnectionDiscoveryTask.result.get()
        }
        
        return try await ongoingConnectionDiscoveryTask.result.get()
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
        hasher.combine(baseUrl)
        hasher.combine(username)
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
