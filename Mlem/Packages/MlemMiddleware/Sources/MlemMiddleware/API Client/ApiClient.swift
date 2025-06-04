//
//  ApiClient.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Combine
import Foundation

@Observable
public class ApiClient {
    // url and username MAY NOT be modified! Downstream code expects that a given ApiClient will *always* submit requests from the same user to the same instance.
    public let baseUrl: URL
    public let username: String?
    
    var restClient: RestClient<ApiErrorResponse> = .init()
    
    public internal(set) var token: String?
    
    public private(set) var contextDataManager: SharedTaskManager<Context> = .init()
    
    public var willSendToken: Bool { token != nil }
    
    public internal(set) weak var myInstance: Instance3?
    public internal(set) weak var myPerson: Person4?
    public internal(set) weak var subscriptions: SubscriptionList?
    public internal(set) weak var blocks: BlockList?
    public internal(set) weak var unreadCount: UnreadCount?
    
    /// Stores the IDs of posts that are queued to be marked read.
    var markReadQueue: MarkReadQueue = .init()
    
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
        fetchedVersion?.suppports(feature) ?? false
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
        token = newToken
    }
    
    @discardableResult
    func perform<Request: ApiRequest>(
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

public extension ApiClient {
    struct Context {
        let siteVersion: SiteVersion
        let myPersonId: Int?
    }
}

public extension ApiClient.Context {
    init(instance: Instance3, person: Person4?) {
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
