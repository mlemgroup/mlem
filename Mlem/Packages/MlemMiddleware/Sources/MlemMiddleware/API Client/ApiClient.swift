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
    // url and username MAY NOT be modified! Downstream code expects that a given ApiClient will *always* submit requests from the same user to the same instance.
    public let baseUrl: URL
    public let username: String?
    
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
        try await getLemmyConnection().ensureContextPresence()
    }
    
    public func supports(_ feature: Feature) async throws -> Bool {
        try await getLemmyConnection().supports(feature)
    }
    
    public func supportsOrNil(_ feature: Feature) -> Bool? {
        getLemmyConnection().supportsOrNil(feature)
    }
    
    public var contextIsFetched: Bool {
        getLemmyConnection().contextIsFetched
    }

    public var myPersonId: Int? {
        get async throws {
            try await getLemmyConnection().myPersonId
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
    
    func performingForConnection<T>(
        _ callback: (any InstanceConnection) async throws -> T
    ) async throws -> T {
        try await callback(getLemmyConnection())
    }
    
    // This is temporary and will be removed shortly
    private func getLemmyConnection() -> any InstanceConnection {
        if let connection {
            return connection
        } else {
            let connection = LemmyConnection(baseUrl: baseUrl, token: token)
            self.connection = connection
            return connection
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
