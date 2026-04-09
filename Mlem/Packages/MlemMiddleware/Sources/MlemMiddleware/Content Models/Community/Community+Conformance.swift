//
//  Community+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-14.
//

import Foundation

// MARK: CacheIdentifiable

public extension Community {
    var cacheId: Int { id }
}

// MARK: CommunityOrPerson

public extension Community {
    static var identifierPrefix: String { "!" }
}

// MARK: Blockable

public extension Community {
    var updateBlocked: ((Bool, ((Bool) -> Void)?) -> Void)? { self._updateBlocked }
    
    private func _updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)? = nil) {
        let oldValue = blocked_.realizedValue
        blocked_.set(newValue)
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.blockCommunity(id: self.id, block: newValue)
                    callback?(true)
                    if newValue {
                        self.api.blocks?.communities[self.actorId] = self.id
                    } else {
                        self.api.blocks?.communities.removeValue(forKey: self.actorId)
                    }
                    return await .init(api: self.api, snapshot: .community2(snapshot))
                } catch {
                    // need to manually roll back because blocked is not included in snapshot informatoin
                    self.blocked_.set(oldValue)
                    callback?(false)
                    throw error
                }
            }
        }
    }
}

// MARK: ContentIdentifiable

public extension Community {
    static var modelTypeId: ContentType { .community }
}

// MARK: CanModerateProviding

public extension Community {
    var canModerate: Bool {
        guard let myPersonModerates = api.myPerson?.moderates else { return false }
        return myPersonModerates(.id(id)) || api.isAdmin
    }
}

// MARK: FeedLoadable

public extension Community {
    typealias FilterType = CommunityFilterType
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}

// MARK: Sharable

public extension Community {
    func url() -> URL {
        if apiIsLocal {
            api.baseUrl.appending(path: "c/\(name)")
        } else {
            api.baseUrl.appending(path: "c/\(name)@\(host)")
        }
    }
}

// MARK: Resolvable

public extension Community {
    /// Returns a `URL` that can be resolved by another `ApiClient`.
    func resolvableUrl(from instance: ContentModelUrlType) -> URL {
        switch instance {
        case .host: actorId.url
        case .provider: .community(host: api.host, name: name)
        }
    }
    
    @inlinable
    var allResolvableUrls: [URL] {
        ContentModelUrlType.allCases.map { resolvableUrl(from: $0) }
    }
}

// MARK: Codable

public extension Community {
    struct CodedData: Codable {
        let apiUrl: URL
        let apiMyPersonId: Int?
        let apiCommunity: LemmyCommunity
    }
    
    internal var apiCommunity: LemmyCommunity {
        LemmyCommunity(
            id: id,
            name: name,
            title: displayName,
            description: description,
            removed: removed,
            published: created,
            updated: updated,
            deleted: deleted,
            nsfw: nsfw,
            actorId: actorId,
            local: apiIsLocal,
            icon: avatar,
            banner: banner,
            hidden: hidden,
            postingRestrictedToMods: onlyModeratorsCanPost,
            instanceId: instanceId,
            visibility: nil,
            sidebar: nil,
            publishedAt: created,
            updatedAt: updated,
            apId: actorId,
            lastRefreshedAt: nil,
            summary: nil,
            subscribers: nil,
            posts: nil,
            comments: nil,
            usersActiveDay: nil,
            usersActiveWeek: nil,
            usersActiveMonth: nil,
            usersActiveHalfYear: nil,
            subscribersLocal: nil,
            reportCount: nil,
            unresolvedReportCount: nil,
            localRemoved: nil
        )
    }
    
    func codedData() async throws -> CodedData {
        try await .init(
            apiUrl: api.baseUrl,
            apiMyPersonId: api.myPersonId,
            apiCommunity: apiCommunity
        )
    }
}
