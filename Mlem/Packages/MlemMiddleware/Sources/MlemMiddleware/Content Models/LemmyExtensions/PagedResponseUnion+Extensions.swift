//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-12-05.
//  

import Foundation

extension LemmyListCommentsResponseUnion {
    var items: [LemmyCommentView] {
        switch self {
        case let .lemmyGetCommentsResponse(response): response.comments
        case let .lemmyPagedResponse(response): response.items
        }
    }
    
    var nextPage: String? {
        switch self {
        case .lemmyGetCommentsResponse: nil
        case let .lemmyPagedResponse(response): response.nextPage
        }
    }
}

extension LemmyListPostsResponseUnion {
    var items: [LemmyPostView] {
        switch self {
        case let .lemmyGetPostsResponse(response): response.posts
        case let .lemmyPagedResponse(response): response.items
        }
    }
    
    var nextPage: String? {
        switch self {
        case .lemmyGetPostsResponse: nil
        case let .lemmyPagedResponse(response): response.nextPage
        }
    }
}

extension LemmyListCommentLikesResponseUnion {
    var items: [LemmyVoteView] {
        switch self {
        case let .lemmyListCommentLikesResponse(response): response.commentLikes
        case let .lemmyPagedResponse(response): response.items
        }
    }
    
    var nextPage: String? {
        switch self {
        case .lemmyListCommentLikesResponse: nil
        case let .lemmyPagedResponse(response): response.nextPage
        }
    }
}

extension LemmyListPostLikesResponseUnion {
    var items: [LemmyVoteView] {
        switch self {
        case let .lemmyListPostLikesResponse(response): response.postLikes
        case let .lemmyPagedResponse(response): response.items
        }
    }
    
    var nextPage: String? {
        switch self {
        case .lemmyListPostLikesResponse: nil
        case let .lemmyPagedResponse(response): response.nextPage
        }
    }
}

extension LemmyListCommunitiesResponseUnion {
    var items: [LemmyCommunityView] {
        switch self {
        case let .lemmyListCommunitiesResponse(response): response.communities
        case let .lemmyPagedResponse(response): response.items
        }
    }
    
    var prevPage: String? {
        switch self {
        case .lemmyListCommunitiesResponse: nil
        case let .lemmyPagedResponse(response): response.prevPage
        }
    }

    var nextPage: String? {
        switch self {
        case .lemmyListCommunitiesResponse: nil
        case let .lemmyPagedResponse(response): response.nextPage
        }
    }

    func toPagedResponse() -> LemmyPagedResponse<LemmyCommunityView> {
        .init(
            items: items,
            nextPage: nextPage,
            prevPage: prevPage
        )
    }
}

extension LemmyListRegistrationApplicationsResponseUnion {
    var items: [LemmyRegistrationApplicationView] {
        switch self {
        case let .lemmyListRegistrationApplicationsResponse(response): response.registrationApplications
        case let .lemmyPagedResponse(response): response.items
        }
    }
    
    var nextPage: String? {
        switch self {
        case .lemmyListRegistrationApplicationsResponse: nil
        case let .lemmyPagedResponse(response): response.nextPage
        }
    }
}
