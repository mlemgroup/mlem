//
//  LemmyPersonSavedCombinedView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-11-25.
//

import Foundation

extension LemmyPostCommentCombinedView {
    var postValue: LemmyPostView {
        get throws(ApiClientError) {
            switch self {
            case let .post(post): post
            case .comment: throw ApiClientError.responseMissingRequiredData("LemmyPostCommentCombinedView post")
            }
        }
    }

    var commentValue: LemmyCommentView {
        get throws(ApiClientError) {
            switch self {
            case let .comment(comment): comment
            case .post: throw ApiClientError.responseMissingRequiredData("LemmyPostCommentCombinedView comment")
            }
        }
    }
}

extension LemmyPagedResponse<LemmyPostCommentCombinedView> {
    func toPostsResponse() throws(ApiClientError) -> LemmyPagedResponse<LemmyPostView> {
        .init(
            items: try self.items.map { post throws(ApiClientError) in try post.postValue },
            nextPage: self.nextPage,
            prevPage: self.prevPage
        )
    }

    func toCommentsResponse() throws(ApiClientError) -> LemmyPagedResponse<LemmyCommentView> {
        .init(
            items: try self.items.map { comment throws(ApiClientError) in try comment.commentValue },
            nextPage: self.nextPage,
            prevPage: self.prevPage
        )
    }
}
