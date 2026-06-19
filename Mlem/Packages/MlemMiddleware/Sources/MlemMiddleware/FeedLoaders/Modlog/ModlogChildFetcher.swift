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
    var moderatorPersonId: Int?
    var type: ModlogEntryType
    
    init(
        api: ApiClient,
        pageSize: Int,
        sharedCache: SharedCache,
        communityId: Int?,
        targetPersonId: Int?,
        moderatorPersonId: Int?,
        type: ModlogEntryType
    ) {
        self.communityId = communityId
        self.targetPersonId = targetPersonId
        self.moderatorPersonId = moderatorPersonId
        self.type = type
        self.sharedCache = sharedCache
        super.init(api: api, pageSize: pageSize)
    }
    
    override func fetchContent(_ pageInfo: PageInfo) async throws -> PagedResponse<ModlogEntry> {
        if pageInfo.cursor == .first {
             try await sharedCache.get(type: type)
        } else {
             try await api.getModlog(
                pageInfo: pageInfo,
                communityId: communityId,
                moderatorId: moderatorPersonId,
                subjectPersonId: targetPersonId,
                type: type
            )
        }
    }
}
