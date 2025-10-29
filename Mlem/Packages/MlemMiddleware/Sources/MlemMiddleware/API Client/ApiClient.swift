//
//  ApiClient.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Combine
import Foundation
import os
import Rest

@Observable
public class ApiClient {
    let log: Logger = .mlemLogger()
    
    var repository: ApiRepository
    
    public var willSendToken: Bool { repository.token != nil }
    
    public internal(set) weak var myInstance: Instance3?
    public internal(set) weak var myPerson: Person4?
    public internal(set) weak var subscriptions: SubscriptionList?
    public internal(set) weak var blocks: BlockList?
    public internal(set) weak var unreadCount: UnreadCount?
    
    /// Stores the IDs of posts that are queued to be marked read.
    var markReadQueue: MarkReadQueue = .init()
    
    public func ensureContextPresence() async throws {
        try await repository.getConnection().ensureContextPresence()
    }
    
    public func supports(_ feature: Feature) async throws -> Bool {
        try await repository.getConnection().supports(feature)
    }
    
    /// Returns whether this `ApiClient` supports the given feature. If this information cannot be resolved, returns the provided `defaultValue`
    public func supports(_ feature: Feature, defaultValue: Bool) -> Bool {
        repository.connection?.supports(feature, defaultValue: defaultValue) ?? defaultValue
    }
    
    public var contextIsFetched: Bool {
        repository.connection?.contextIsFetched ?? false
    }

    public var username: String? { repository.username }
    
    public var baseUrl: URL { repository.baseUrl }
    
    public var token: String? { repository.token }
    
    public var myPersonId: Int? {
        get async throws {
            try await repository.getConnection().myPersonId
        }
    }
    
    public var software: SiteSoftware {
        get async throws {
            let connection = try await repository.getConnection()
            return try await .init(type: type(of: connection).softwareType, version: connection.version)
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
        self.repository = .init(baseUrl: url, username: username)
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
        repository.updateToken(newToken)
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
        "ApiClient(\(host), authenticated: \(repository.token != nil))"
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
