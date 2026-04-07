//
//  Person+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Foundation

// MARK: CacheIdentifiable

public extension Person {
    var cacheId: Int { id }
}

// MARK: SelectableContentProviding

public extension Person {
    var selectableContent: String? { description }
}

// MARK: CommunityOrPerson

public extension Person {
    static var identifierPrefix: String { "@" }
}

// MARK: ContentIdentifiable

public extension Person {
    static var modelTypeId: ContentType { .person }
}

// MARK: Resolvable

public extension Person {
    /// Returns a `URL` that can be resolved by another `ApiClient`.
    func resolvableUrl(from instance: ContentModelUrlType) -> URL {
        switch instance {
        case .host: actorId.url
        case .provider: .person(host: api.host, name: name)
        }
    }
    
    @inlinable
    var allResolvableUrls: [URL] {
        ContentModelUrlType.allCases.map { resolvableUrl(from: $0) }
    }
}

// MARK: Sharable

public extension Person {
    func url() -> URL {
        if apiIsLocal {
            api.baseUrl.appending(path: "u/\(name)")
        } else {
            api.baseUrl.appending(path: "u/\(name)@\(host)")
        }
    }
}

// MARK: FeedLoadable

public extension Person {
    typealias FilterType = PersonFilterType
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}

// MARK: Blockable

public extension Person {
    var blockedValue: Bool { blocked } // TODO: Unified Instance replace with RealizedValueProviding
    
    var updateBlocked: ((Bool, ((Bool) -> Void)?) -> Void)? { self._updateBlocked }
    
    private func _updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)? = nil) {
        let oldValue = blocked
        blocked_.set(newValue)
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.blockPerson(id: self.id, block: newValue)
                    callback?(true)
                    if newValue {
                        self.api.blocks?.people[self.actorId] = self.id
                    } else {
                        self.api.blocks?.people.removeValue(forKey: self.actorId)
                    }
                    return await .init(api: self.api, snapshot: .person2(snapshot))
                } catch {
                    self.blocked_.set(oldValue)
                    callback?(false)
                    throw error
                }
            }
        }
    }
}

// MARK: Codable

public extension Person {
    struct CodedData: Codable {
        let apiUrl: URL
        let apiMyPersonId: Int?
        let apiPerson: LemmyPerson
    }
    
    internal var apiPerson: LemmyPerson {
        .init(
            id: id,
            name: name,
            displayName: displayName == name ? nil : displayName,
            avatar: avatar,
            banned: bannedFromInstance,
            published: created,
            updated: updated,
            actorId: actorId,
            bio: description,
            local: apiIsLocal,
            banner: banner,
            deleted: deleted,
            matrixUserId: matrixUserId,
            botAccount: isBot,
            banExpires: instanceBan.expiryDate,
            instanceId: instanceId,
            publishedAt: created,
            updatedAt: updated,
            apId: actorId,
            lastRefreshedAt: nil,
            postCount: nil,
            commentCount: nil
        )
    }
    
    func codedData() async throws -> CodedData {
        try await .init(
            apiUrl: api.baseUrl,
            apiMyPersonId: api.myPersonId,
            apiPerson: apiPerson
        )
    }
}
