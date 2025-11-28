//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public extension PieFedConnection {
    func getComment(id: Int) async throws -> Comment2Snapshot {
        let request = PieFedGetCommentRequest(id: id)
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        do {
            let request = PieFedResolveObjectRequest(q: url.absoluteString)
            let response = try await perform(request)
            if let comment = response.comment {
                return try .init(from: comment)
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
        throw ApiClientError.noEntityFound
    }
    
    func getComments(
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        guard let sort = sort.piefedCommentSortType, filter != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: page,
            limit: limit,
            communityId: nil,
            postId: nil,
            parentId: nil,
            personId: nil,
            likedOnly: filter == .upvoted,
            savedOnly: filter == .saved,
            depthFirst: false
        )
        let response = try await perform(request)
        return try response.comments.map { try .init(from: $0) }
    }

    func getComments(
        postId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        guard let sort = sort.piefedCommentSortType, filter != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: page,
            limit: limit,
            communityId: nil,
            postId: postId,
            parentId: nil,
            personId: nil,
            likedOnly: filter == .upvoted,
            savedOnly: filter == .saved,
            depthFirst: false
        )
        let response = try await perform(request)
        return try response.comments.map { try .init(from: $0) }
    }
    
    func getComments(
        parentId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        guard let sort = sort.piefedCommentSortType, filter != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: page,
            limit: limit,
            communityId: nil,
            postId: nil,
            parentId: parentId,
            personId: nil,
            likedOnly: filter == .upvoted,
            savedOnly: filter == .saved,
            depthFirst: false
        )
        let response = try await perform(request)
        return try response.comments.map { try .init(from: $0) }
    }

    func getCommentHistory(
        type: GetContentFilter,
        page: Int?,
        cursor: String?,
        limit: Int
    ) async throws -> (comments: [Comment2Snapshot], cursor: String?) {
        guard type != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: nil,
            maxDepth: nil,
            page: page,
            limit: limit,
            communityId: nil,
            postId: nil,
            parentId: nil,
            personId: nil,
            likedOnly: type == .upvoted,
            savedOnly: type == .saved,
            depthFirst: false
        )
        let response = try await perform(request)
        return try (
            comments: response.comments.map { try .init(from: $0) },
            cursor: nil
        )
    }
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: CommentSortType = .top(.allTime)
    ) async throws -> [Comment2Snapshot] {
        throw ApiClientError.featureUnsupported
        // guard let sort = sort.piefedSortType else {
        //     throw ApiClientError.featureUnsupported
        // }
        // let request = PieFedSearchRequest(
        //     q: query,
        //     type_: .comments,
        //     sort: sort,
        //     listingType: filter.pieFedListingType,
        //     page: page,
        //     limit: limit,
        //     communityName: nil,
        //     communityId: communityId
        // )
        // let response = try await perform(request)
        // return try response.posts.map { try .init(from: $0) }
    }
    
    func searchComments(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Comment2Snapshot] {
        throw ApiClientError.featureUnsupported
    }

    private func searchComments(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        legacySort: LemmySortType?,
        sort: LemmySearchSortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Comment2Snapshot] {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation) async throws -> Comment2Snapshot {
        let request = PieFedLikeCommentRequest(
            commentId: id,
            score: score.rawValue,
            private: false
        )
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func saveComment(id: Int, save: Bool) async throws -> Comment2Snapshot {
        let request = PieFedSaveCommentRequest(commentId: id, save: save)
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func deleteComment(id: Int, delete: Bool) async throws -> Comment2Snapshot {
        let request = PieFedDeleteCommentRequest(commentId: id, deleted: delete)
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2Snapshot {
        let request = PieFedEditCommentRequest(
            commentId: id,
            body: content,
            languageId: languageId,
            distinguished: false
        )
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    func replyToComment(
        postId: Int,
        parentId: Int?,
        content: String,
        languageId: Int? = nil
    ) async throws -> Comment2Snapshot {
        let request = PieFedCreateCommentRequest(
            body: content,
            postId: postId,
            parentId: parentId,
            languageId: languageId
        )
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> ReportSnapshot {
        let request = PieFedCreateCommentReportRequest(
            commentId: id,
            reason: reason,
            description: nil,
            reportRemote: nil
        )
        let response = try await perform(request)
        return try .init(from: response.commentReportView)
    }
    
    func purgeComment(id: Int, reason: String?) async throws {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func removeComment(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Comment2Snapshot {
        let request = PieFedRemoveCommentRequest(commentId: id, removed: remove, reason: reason)
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func getCommentVotes(
        id: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        let request = PieFedListCommentLikesRequest(commentId: id, page: page, limit: limit)
        let response = try await perform(request)
        return try response.commentLikes.map { try .init(from: $0) }
    }
}
