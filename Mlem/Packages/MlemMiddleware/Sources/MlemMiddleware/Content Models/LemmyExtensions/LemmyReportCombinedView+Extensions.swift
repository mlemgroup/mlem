//
//  LemmyReportCombinedView+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-11-25.
//

import Foundation

extension LemmyReportCombinedView {
    var postValue: LemmyPostReportView {
        get throws(ApiClientError) {
            switch self {
            case let .post(post): post
            case .comment, .privateMessage, .community: throw ApiClientError.responseMissingRequiredData("LemmyReportCombinedView post")
            }
        }
    }

    var commentValue: LemmyCommentReportView {
        get throws(ApiClientError) {
            switch self {
            case let .comment(comment): comment
            case .post, .privateMessage, .community: throw ApiClientError.responseMissingRequiredData("LemmyReportCombinedView comment")
            }
        }
    }

    var privateMessageValue: LemmyPrivateMessageReportView {
        get throws(ApiClientError) {
            switch self {
            case let .privateMessage(privateMessage): privateMessage
            case .post, .comment, .community: throw ApiClientError.responseMissingRequiredData("LemmyReportCombinedView privateMessage")
            }
        }
    }

    var communityValue: LemmyCommunityReportView {
        get throws(ApiClientError) {
            switch self {
            case let .community(community): community
            case .post, .comment, .privateMessage: throw ApiClientError.responseMissingRequiredData("LemmyReportCombinedView community")
            }
        }
    }
}

extension LemmyPagedResponse<LemmyReportCombinedView> {
    func toPostReportsResponse() throws(ApiClientError) -> LemmyPagedResponse<LemmyPostReportView> {
        .init(
            items: try self.items.map { post throws(ApiClientError) in try post.postValue },
            nextPage: self.nextPage,
            prevPage: self.prevPage
        )
    }

    func toCommentReportsResponse() throws(ApiClientError) -> LemmyPagedResponse<LemmyCommentReportView> {
        .init(
            items: try self.items.map { comment throws(ApiClientError) in try comment.commentValue },
            nextPage: self.nextPage,
            prevPage: self.prevPage
        )
    }

    func toPrivateMessageReportsResponse() throws(ApiClientError) -> LemmyPagedResponse<LemmyPrivateMessageReportView> {
        .init(
            items: try self.items.map { privateMessage throws(ApiClientError) in try privateMessage.privateMessageValue },
            nextPage: self.nextPage,
            prevPage: self.prevPage
        )
    }

    func toCommunityReportsResponse() throws(ApiClientError) -> LemmyPagedResponse<LemmyCommunityReportView> {
        .init(
            items: try self.items.map { community throws(ApiClientError) in try community.communityValue },
            nextPage: self.nextPage,
            prevPage: self.prevPage
        )
    }
}
