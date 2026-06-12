//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

internal extension PieFedConnection {
    func getComment(id: Int) async throws -> Comment2Snapshot {
        let request = PieFedGetCommentRequest(id: id)
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        let request = PieFedResolveObjectRequest(q: url.absoluteString)
        let response = try await perform(request)
        if let comment = response.comment {
            return try .init(from: comment)
        }
        throw ApiClientError.noEntityFound
    }
    
    func getComments(
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        guard let sort = sort.piefedCommentSortType, filter != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            communityId: nil,
            postId: nil,
            parentId: nil,
            personId: nil,
            likedOnly: filter == .upvoted,
            savedOnly: filter == .saved,
            depthFirst: false
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.comments.map { try .init(from: $0) }
        )
    }

    func getComments(
        postId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        guard let sort = sort.piefedCommentSortType, filter != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: try pageInfo.cursor.requirePageNumber,
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
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.comments.map { try .init(from: $0) }
        )
    }
    
    func getComments(
        parentId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        guard let sort = sort.piefedCommentSortType, filter != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            communityId: nil,
            postId: nil,
            parentId: parentId,
            personId: nil,
            likedOnly: filter == .upvoted,
            savedOnly: filter == .saved,
            depthFirst: false
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.comments.map { try .init(from: $0) }
        )
    }

    func getCommentHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Comment2Snapshot> {
        guard type != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: nil,
            maxDepth: nil,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            communityId: nil,
            postId: nil,
            parentId: nil,
            personId: nil,
            likedOnly: type == .upvoted,
            savedOnly: type == .saved,
            depthFirst: false
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.comments.map { try .init(from: $0) }
        )
    }
    
    func searchComments(
        query: String,
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: CommentSortType = .top(.allTime)
    ) async throws -> PagedResponse<Comment2Snapshot> {
        guard let sort = sort.piefedSearchSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedSearchRequest(
            q: query,
            type_: .comments,
            sort: sort,
            listingType: filter.pieFedListingType,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            communityName: nil,
            communityId: communityId,
            minimumUpvotes: nil,
            nsfw: nil
        )
        let response = try await perform(request)
        guard let comments = response.comments else {
            throw ApiClientError.featureUnsupported
        }
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try comments.map { try .init(from: $0) }
        )
    }
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation) async throws -> Comment2Snapshot {
        let request = PieFedLikeCommentRequest(
            commentId: id,
            score: score.rawValue,
            private: false,
            emoji: nil
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
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVoteSnapshot> {
        let request = PieFedListCommentLikesRequest(
            commentId: id,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.commentLikes.map { try .init(from: $0) }
        )
    }
}
