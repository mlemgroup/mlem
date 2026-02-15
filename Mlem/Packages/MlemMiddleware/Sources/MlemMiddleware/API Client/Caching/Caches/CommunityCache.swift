//
//  CommunityCache.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public enum AnyCommunitySnapshot: CacheIdentifiable {
    case community1(Community1Snapshot)
    case community2(Community2Snapshot)
    case community3(Community3Snapshot)
    
    public var cacheId: Int {
        switch self {
        case let .community1(snapshot): snapshot.cacheId
        case let .community2(snapshot): snapshot.cacheId
        case let .community3(snapshot): snapshot.cacheId
        }
    }
}

class CommunityCache: ApiTypeBackedCache<Community, AnyCommunitySnapshot> {
    override func performModelTranslation(api: ApiClient, from apiType: AnyCommunitySnapshot) -> Community {
        return .init(api: api, properties: .init(api: api, snapshot: apiType))
    }
    
    override func updateModel(_ item: Community, with apiType: AnyCommunitySnapshot, semaphore: UInt? = nil) {
        // attempt a direct update through the queue to avoid overwriting more recent data, and also
        // synchronously perform softUpdate to ensure high-tier data is available where expected
        let properties: CommunityProperties = .init(api: item.api, snapshot: apiType)
        Task {
            await item.updateQueue.attemptDirectUpdate(with: properties)
        }
        item.softUpdate(with: properties)
    }
}
