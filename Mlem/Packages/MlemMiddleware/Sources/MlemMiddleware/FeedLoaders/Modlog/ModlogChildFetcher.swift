//
//  ModlogChildFetcher.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-28.
//

import Foundation

@Observable
public class ModlogChildFetcher: Fetcher<ModlogEntry> {
    let sharedCache: SharedCache
    var communityId: Int?
    var targetPersonId: Int?
    var type: ModlogEntryType
    
    init(
        api: ApiClient,
        pageSize: Int,
        sharedCache: SharedCache,
        communityId: Int?,
        targetPersonId: Int?,
        type: ModlogEntryType
    ) {
        self.communityId = communityId
        self.targetPersonId = targetPersonId
        self.type = type
        self.sharedCache = sharedCache
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetchPage(_ page: Int) async throws -> FetchResponse {
        let items: [ModlogEntry]
        if page == 1 {
            items = try await sharedCache.get(type: type)
        } else {
            items = try await api.getModlog(
                page: page,
                limit: pageSize,
                communityId: communityId,
                subjectPersonId: targetPersonId,
                type: type
            )
        }
        
        return .init(
            items: items,
            prevCursor: nil,
            nextCursor: nil
        )
    }
}
