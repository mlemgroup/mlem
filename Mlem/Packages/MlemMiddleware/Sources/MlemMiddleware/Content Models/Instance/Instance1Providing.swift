//
//  Instance1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public protocol Instance1Providing:
    Profile2Providing,
    ActorIdentifiable,
    ContentIdentifiable,
    InstanceStubProviding,
    ContentModel {
    var instance1: Instance1 { get }
    
    var id: Int { get }
    /// This ID is different from `id`, and should be used when blocking an instance.
    var instanceId: Int { get }
    var publicKey: String { get }
    var lastRefresh: Date { get }
    var local: Bool { get }
    var shortDescription: String? { get }
    var contentWarning: String? { get }
    var blocked: Bool { get }
}

public typealias Instance = Instance1Providing

public extension Instance1Providing {
    static var modelTypeId: ContentType { .instance }
    
    var actorId: ActorIdentifier { instance1.actorId }
    var id: Int { instance1.id }
    var instanceId: Int { instance1.instanceId }
    var displayName: String { instance1.displayName }
    var description: String? { instance1.description }
    var shortDescription: String? { instance1.shortDescription }
    var avatar: URL? { instance1.avatar }
    var banner: URL? { instance1.banner }
    var created: Date { instance1.created }
    var updated: Date? { instance1.updated }
    var publicKey: String { instance1.publicKey }
    var lastRefresh: Date { instance1.lastRefresh }
    internal(set) var local: Bool { get { instance1.local } set {
        instance1.local = newValue
    }}
    var contentWarning: String? { instance1.contentWarning }
    var blocked: Bool { instance1.blocked }
    
    var id_: Int? { instance1.id }
    var instanceId_: Int { instance1.instanceId }
    var displayName_: String? { instance1.displayName }
    var description_: String? { instance1.description }
    var shortDescription_: String? { instance1.shortDescription }
    var avatar_: URL? { instance1.avatar }
    var banner_: URL? { instance1.banner }
    var created_: Date? { instance1.created }
    var updated_: Date? { instance1.updated }
    var publicKey_: String? { instance1.publicKey }
    var lastRefresh_: Date? { instance1.lastRefresh }
    var contentWarning_: String? { instance1.contentWarning }
    var blocked_: Bool? { instance1.blocked }
}

public extension Instance1Providing {
    private var blockedManager: StateManager<Bool> { instance1.blockedManager }
    
    @inlinable
    var name: String { host } // TODO: Remove this?
    
    var guestApi: ApiClient {
        .getApiClient(url: local ? api.baseUrl : actorId.hostUrl, username: nil)
    }
    
    @discardableResult
    func updateBlocked(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        blockedManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.blockInstance(
                url: self.actorId.url,
                instanceId: self.instanceId,
                block: newValue, semaphore: semaphore
            )
        }
    }
    
    @discardableResult
    func toggleBlocked() -> Task<StateUpdateResult, Never> {
        updateBlocked(!blocked)
    }
}
