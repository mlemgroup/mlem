//
//  NEW PostTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Dependencies
import Foundation

enum NewFeedType {
    case all
    
    var toLegacyFeedType: FeedType {
        switch self {
        case .all:
            return .all
        }
    }
}

class NewPostTracker: StandardTracker<PostModel> {
    @Dependency(\.postRepository) var postRepository
    
    var unreadOnly: Bool
    var feedType: NewFeedType
    var postSortType: PostSortType
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, unreadOnly: Bool, feedType: NewFeedType) {
        self.unreadOnly = unreadOnly
        self.feedType = feedType
        
        // TODO: ERIC handle sort type
        self.postSortType = .new
        
        super.init(internetSpeed: internetSpeed, sortType: sortType)
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
