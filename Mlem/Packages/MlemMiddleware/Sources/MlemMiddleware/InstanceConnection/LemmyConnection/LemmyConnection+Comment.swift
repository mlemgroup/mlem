//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

internal extension LemmyConnection {
    func getComment(id: Int) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetCommentRequest(endpoint: endpoint, id: id)
        }
        return try .init(from: response.commentView)
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        let result = try await resolve(url: url)
        switch result {
        case let .comment(comment):
            return comment
        default:
            throw ApiClientError.noEntityFound
        }
    }
    
    func getComments(
        sort: CommentSortType,
        pageInfo: PageInfo,
        maxDepth: Int?,
        filter: GetContentFilter?
    ) async throws -> PagedResponse<Comment2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmyListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.v3CommentApiType,
                maxDepth: maxDepth,
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                communityId: nil,
                communityName: nil,
                postId: nil,
                parentId: nil,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                timeRangeSeconds: sort.timeRangeSeconds,
                pageCursor: nil,
                creatorId: nil,
                creatorUsername: nil,
                searchTerm: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.items.map { try .init(from: $0) },
            nextCursor: nil
        )
    }

    func getComments(
        postId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmyListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.v3CommentApiType,
                maxDepth: maxDepth,
                page: pageInfo.cursor.pageNumber,
                limit: pageInfo.limit,
                communityId: nil,
                communityName: nil,
                postId: postId,
                parentId: nil,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                timeRangeSeconds: sort.timeRangeSeconds,
                pageCursor: pageInfo.cursor.cursorString,
                creatorId: nil,
                creatorUsername: nil,
                searchTerm: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.items.map { try .init(from: $0) },
            nextCursor: response.nextPage
        )
    }
    
    func getComments(
        parentId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmyListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.v3CommentApiType,
                maxDepth: maxDepth,
                page: pageInfo.cursor.pageNumber,
                limit: pageInfo.limit,
                communityId: nil,
                communityName: nil,
                postId: nil,
                parentId: parentId,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                timeRangeSeconds: sort.timeRangeSeconds,
                pageCursor: pageInfo.cursor.cursorString,
                creatorId: nil,
                creatorUsername: nil,
                searchTerm: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.items.map { try .init(from: $0) },
            nextCursor: response.nextPage
        )
    }

    func getCommentHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Comment2Snapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                // Cursors are supported on v3, but are super slow when
                // querying saved posts. For that reason, we're considering them
                // unsupported and requiring a page number instead.
                // See LemmyNet/lemmy#6171

                let page = try pageInfo.cursor.requirePageNumber

                let request = LemmyListCommentsRequest(
                    endpoint: .v3,
                    type_: .all,
                    sort: .new,
                    maxDepth: nil,
                    page: page,
                    limit: pageInfo.limit,
                    communityId: nil,
                    communityName: nil,
                    postId: nil,
                    parentId: nil,
                    savedOnly: type == .saved,
                    likedOnly: type == .upvoted,
                    dislikedOnly: type == .downvoted,
                    timeRangeSeconds: nil,
                    pageCursor: nil,
                    creatorId: nil,
                    creatorUsername: nil,
                    searchTerm: nil
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.items.map { try .init(from: $0) },
                    // Cursor intentionally omitted here. See comment above
                    nextCursor: nil
                )
            case .v4:
                let response = try await self.v4GetCommentHistory(type: type, pageInfo: pageInfo)
                return try .init(from: response.toCommentsResponse()) { try .init(from: $0) }
            }
        }
    }
    
    private func v4GetCommentHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> LemmyPagedResponse<LemmyPostCommentCombinedView> {
        let cursorString = try pageInfo.cursor.requireCursorString

        switch type {
        case .saved:
            let request = LemmyListPersonSavedRequest(
                type_: .all,
                searchTerm: nil,
                pageCursor: cursorString,
                limit: pageInfo.limit
            )
            return try await self.perform(request, endpoint: .v4)
        case .upvoted, .downvoted:
            let request = LemmyListPersonLikedRequest(
                type_: .all,
                likeType: type == .upvoted ? .likedOnly : .dislikedOnly,
                pageCursor: cursorString,
                limit: pageInfo.limit
            )
            return try await self.perform(request, endpoint: .v4)
        }
    }

    func searchComments(
        query: String,
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: CommentSortType = .top(.allTime)
    ) async throws -> PagedResponse<Comment2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmySearchRequest(
                endpoint: endpoint,
                q: query,
                communityId: communityId,
                communityName: nil,
                creatorId: creatorId,
                type_: .comments,
                sort: sort.v3PostApiType,
                listingType: filter.apiType,
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                postTitleOnly: false,
                searchTerm: query,
                creatorUsername: nil,
                timeRangeSeconds: nil,
                titleOnly: nil,
                postUrlOnly: nil,
                showNsfw: nil,
                pageCursor: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.comments.map { try .init(from: $0) },
            nextCursor: nil
        )
    }
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyLikeCommentRequest(
                endpoint: endpoint,
                commentId: id,
                score: score.rawValue,
                isUpvote: score.booleanValue
            )
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func saveComment(id: Int, save: Bool) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmySaveCommentRequest(endpoint: endpoint, commentId: id, save: save)
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func deleteComment(id: Int, delete: Bool) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyDeleteCommentRequest(endpoint: endpoint, commentId: id, deleted: delete)
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyEditCommentRequest(
                endpoint: endpoint,
                commentId: id,
                content: content,
                languageId: languageId
            )
        }
        return try .init(from: response.commentView)
    }
    
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyCreateCommentRequest(
                endpoint: endpoint,
                content: content,
                postId: postId,
                parentId: parentId,
                languageId: languageId
            )
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyCreateCommentReportRequest(
                endpoint: endpoint,
                commentId: id,
                reason: reason,
                violatesInstanceRules: nil
            )
        }
        return try .init(from: response.commentReportView)
    }
    
    func purgeComment(id: Int, reason: String?) async throws {
        let response = try await performingForEndpoint { endpoint in
            LemmyPurgeCommentRequest(endpoint: endpoint, commentId: id, reason: reason)
        }
        guard response.success else { throw ApiClientError.unsuccessful }
    }
    
    @discardableResult
    func removeComment(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyRemoveCommentRequest(
                endpoint: endpoint,
                commentId: id,
                removed: remove,
                reason: reason,
                removeChildren: nil
            )
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func getCommentVotes(id: Int, pageInfo: PageInfo) async throws -> PagedResponse<PersonVoteSnapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmyListCommentLikesRequest(
                endpoint: endpoint,
                commentId: id,
                page: pageInfo.cursor.pageNumber,
                limit: pageInfo.limit,
                pageCursor: pageInfo.cursor.cursorString
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.items.map { try .init(from: $0) },
            nextCursor: nil
        )
    }
}
