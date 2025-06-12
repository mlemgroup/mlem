//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public extension LemmyConnection {
    func getComment(id: Int) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            GetCommentRequest(endpoint: endpoint, id: id)
        }
        return try .init(from: response.commentView)
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        do {
            let response = try await performingForEndpoint { endpoint in
                ResolveObjectRequest(endpoint: endpoint, q: url.absoluteString)
            }
            if let comment = response.comment {
                return try .init(from: comment)
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
        throw ApiClientError.noEntityFound
    }
    
    func getComments(
        postId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            ListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.apiSortType,
                maxDepth: maxDepth,
                page: page,
                limit: limit,
                communityId: nil,
                communityName: nil,
                postId: postId,
                parentId: nil,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                timeRangeSeconds: nil,
                pageCursor: nil,
                pageBack: nil
            )
        }
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
        let response = try await performingForEndpoint { endpoint in
            ListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.apiSortType,
                maxDepth: maxDepth,
                page: page,
                limit: limit,
                communityId: nil,
                communityName: nil,
                postId: nil,
                parentId: parentId,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                timeRangeSeconds: nil,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.comments.map { try .init(from: $0) }
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
        try await searchComments(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            legacySort: sort.legacyApiSortType,
            sort: sort.apiSearchSortType,
            timeRangeSeconds: sort.timeRangeSeconds
        )
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
        try await searchComments(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            legacySort: sort.legacyApiSortType,
            sort: sort.apiSortType,
            timeRangeSeconds: sort.timeRangeSeconds
        )
    }

    private func searchComments(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        legacySort: ApiSortType?,
        sort: ApiSearchSortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Comment2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            SearchRequest(
                endpoint: .v3,
                q: query,
                communityId: communityId,
                communityName: nil,
                creatorId: creatorId,
                type_: .comments,
                sort: .init(oldSortType: endpoint == .v3 ? legacySort : nil, newSortType: endpoint == .v4 ? sort : nil),
                listingType: filter.apiType,
                page: page,
                limit: limit,
                postTitleOnly: false,
                searchTerm: nil,
                timeRangeSeconds: timeRangeSeconds,
                titleOnly: nil,
                postUrlOnly: nil,
                likedOnly: nil,
                dislikedOnly: nil,
                showNsfw: nil,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.comments?.map { try .init(from: $0) } ?? []
    }
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LikeCommentRequest(endpoint: endpoint, commentId: id, score: score.rawValue)
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func saveComment(id: Int, save: Bool) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            SaveCommentRequest(endpoint: endpoint, commentId: id, save: save)
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func deleteComment(id: Int, delete: Bool) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            DeleteCommentRequest(endpoint: endpoint, commentId: id, deleted: delete)
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
            UpdateCommentRequest(
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
            CreateCommentRequest(
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
            CreateCommentReportRequest(
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
            PurgeCommentRequest(endpoint: endpoint, commentId: id, reason: reason)
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
            RemoveCommentRequest(
                endpoint: endpoint,
                commentId: id,
                removed: remove,
                reason: reason
            )
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func getCommentVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        let response = try await performingForEndpoint { endpoint in
            ListCommentLikesRequest(
                endpoint: endpoint,
                commentId: id,
                page: page,
                limit: limit,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.commentLikes.map { try .init(from: $0) }
    }
}
