//
//  Person+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Foundation

// MARK: ContentModel

public extension Person {
    static var tierNumber: Int { 4 }
}

// MARK: CacheIdentifiable

public extension Person {
    var cacheId: Int { id }
}

// MARK: SelectableContentProviding

public extension Person {
    var selectableContent: String? { description }
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
    func updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)? = nil) {
        blocked = newValue
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.blockPerson(id: self.id, block: newValue)
                    callback?(true)
                    return await .init(api: self.api, snapshot: .person2(snapshot))
                } catch {
                    callback?(false)
                    throw error
                }
            }
        }
    }
}
