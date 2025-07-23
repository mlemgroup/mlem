//
//  Community1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public protocol Community1Providing:
    CommunityStubProviding,
    Profile2Providing,
    CommunityOrPerson,
    ContentIdentifiable,
    RemovableProviding,
    PurgableProviding,
    Sharable,
    FeedLoadable where FilterType == CommunityFilterType {
    var community1: Community1 { get }
    
    var name: String { get }
    var deleted: Bool { get }
    var nsfw: Bool { get }
    var hidden: Bool { get }
    var onlyModeratorsCanPost: Bool { get }
    var blocked: Bool { get }
}

public typealias Community = Community1Providing

public extension Community1Providing {
    static var modelTypeId: ContentType { .community }
    
    var actorId: ActorIdentifier { community1.actorId }
    var name: String { community1.name }
    
    var id: Int { community1.id }
    var created: Date { community1.created }
    var instanceId: Int { community1.instanceId }
    var updated: Date? { community1.updated }
    var displayName: String { community1.displayName }
    var description: String? { community1.description }
    var removed: Bool { community1.removed }
    var removedPending: Bool { !community1.removedManager.isInSync }
    var deleted: Bool { community1.deleted }
    var nsfw: Bool { community1.nsfw }
    var avatar: URL? { community1.avatar }
    var banner: URL? { community1.banner }
    var hidden: Bool { community1.hidden }
    var onlyModeratorsCanPost: Bool { community1.onlyModeratorsCanPost }
    var blocked: Bool { community1.blocked }
    var purged: Bool { community1.purged }
    
    var actorId_: ActorIdentifier? { community1.actorId }
    var id_: Int? { community1.id }
    var created_: Date? { community1.created }
    var instanceId_: Int? { community1.instanceId }
    var updated_: Date? { community1.updated }
    var name_: String? { community1.name }
    var displayName_: String? { community1.displayName }
    var description_: String? { community1.description }
    var removed_: Bool? { community1.removed }
    var removedManager_: StateManager<Bool>? { community1.removedManager }
    var deleted_: Bool? { community1.deleted }
    var nsfw_: Bool? { community1.nsfw }
    var avatar_: URL? { community1.avatar }
    var banner_: URL? { community1.banner }
    var hidden_: Bool? { community1.hidden }
    var onlyModeratorsCanPost_: Bool? { community1.onlyModeratorsCanPost }
    var blocked_: Bool? { community1.blocked }
    var purged_: Bool? { community1.purged }
}

// Resolvable conformance
public extension Community1Providing {
    @inlinable
    var allResolvableUrls: [URL] {
        ContentModelUrlType.allCases.map { resolvableUrl(from: $0) }
    }
}

// Sharable conformance
public extension Community1Providing {
    func url() -> URL {
        if apiIsLocal {
            api.baseUrl.appending(path: "c/\(name)")
        } else {
            api.baseUrl.appending(path: "c/\(name)@\(host)")
        }
    }
}

// FeedLoadable conformance
public extension Community1Providing {
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}

// SelectableContentProviding conformance
public extension Community1Providing {
    var selectableContent: String? { description }
}

public extension Community1Providing {
    var blockedManager: SyntheticStateManager<Bool> { community1.blockedManager }
    
    /// Returns a `URL` that can be resolved by another `ApiClient`.
    func resolvableUrl(from instance: ContentModelUrlType) -> URL {
        switch instance {
        case .host: actorId.url
        case .provider: .community(host: api.host, name: name)
        }
    }
    
    func upgrade() async throws -> any Community {
        try await api.getCommunity(id: id)
    }
    
    func getPosts(
        sort: PostSortType,
        page: Int = 1,
        cursor: String? = nil,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2], cursor: String?) {
        try await api.getPosts(
            communityId: id,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            filter: filter,
            showHidden: showHidden
        )
    }
    
    @discardableResult
    func updateBlocked(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        blockedManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.blockCommunity(id: self.id, block: newValue, semaphore: semaphore)
        }
    }
    
    @discardableResult
    func toggleBlocked() -> Task<StateUpdateResult, Never> {
        updateBlocked(!blocked)
    }
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((Bool) -> Void)?) throws {
        // TODO: UpdateQueue use queued state management
        _ = community1.removedManager.performRequest(expectedResult: newValue) { semaphore in
            do {
                try await self.api.removeCommunity(id: self.id, remove: newValue, reason: reason, semaphore: semaphore)
                callback?(true)
            } catch {
                callback?(false)
            }
        }
    }
    
    func purge(reason: String?) async throws {
        try await api.purgeCommunity(id: id, reason: reason)
    }
    
    func addModerator(personId: Int, added: Bool) async throws {
        try await api.addModerator(communityId: id, personId: personId, added: added)
    }
    
    func addModerator(_ person: any Person, added: Bool) async throws {
        try await api.addModerator(communityId: id, personId: person.id, added: added)
    }
}
