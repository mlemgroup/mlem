//
//  StandardPostTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Dependencies
import Foundation

// TODO:
// - re-enable hidden item counts

/// Post tracker for use with single feeds. Supports all post sorting types, but is not suitable for multi-feed use.
class StandardPostTracker: StandardTracker<PostModel> {
    @Dependency(\.postRepository) var postRepository
    
    var unreadOnly: Bool
    var feedType: NewFeedType
    private(set) var postSortType: PostSortType
    
    init(internetSpeed: InternetSpeed, sortType: PostSortType, unreadOnly: Bool, feedType: NewFeedType) {
        self.unreadOnly = unreadOnly
        self.feedType = feedType
        self.postSortType = sortType
        
        super.init(internetSpeed: internetSpeed)
    }
    
    override func fetchPage(page: Int) async throws -> (items: [PostModel], cursor: String?) {
        // TODO: ERIC migrate repository to use "items"
        let (items, cursor) = try await postRepository.loadPage(
            communityId: nil,
            page: page,
            cursor: nil,
            sort: postSortType,
            type: feedType.toLegacyFeedType,
            limit: internetSpeed.pageSize
        )
        return (items, cursor)
    }
    
    override func fetchCursor(cursor: String?) async throws -> (items: [PostModel], cursor: String?) {
        // TODO: ERIC migrate repository to use "items"
        let (items, cursor) = try await postRepository.loadPage(
            communityId: nil,
            page: page,
            cursor: cursor,
            sort: postSortType,
            type: feedType.toLegacyFeedType,
            limit: internetSpeed.pageSize
        )
        return (items, cursor)
    }
}
