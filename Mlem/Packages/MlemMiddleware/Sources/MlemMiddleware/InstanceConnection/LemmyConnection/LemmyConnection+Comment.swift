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
            LemmyGetCommentRequest(endpoint: endpoint, id: id)
        }
        return try .init(from: response.commentView)
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        do {
            let result = try await resolve(url: url)
            switch result {
            case let .comment(comment):
                return comment
            default:
                throw ApiClientError.noEntityFound
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
    }
    
    func getComments(
        sort: CommentSortType,
        page: Int,
        maxDepth: Int?,
        limit: Int,
        filter: GetContentFilter?
    ) async throws -> [Comment2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            LemmyListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.v3CommentApiType,
                maxDepth: maxDepth,
                page: page,
                limit: limit,
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
        return try response.items.map { try .init(from: $0) }
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
            LemmyListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.v3CommentApiType,
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
                timeRangeSeconds: sort.timeRangeSeconds,
                pageCursor: nil,
                creatorId: nil,
                creatorUsername: nil,
                searchTerm: nil
            )
        }
        return try response.items.map { try .init(from: $0) }
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
            LemmyListCommentsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.v3CommentApiType,
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
                timeRangeSeconds: sort.timeRangeSeconds,
                pageCursor: nil,
                creatorId: nil,
                creatorUsername: nil,
                searchTerm: nil
            )
        }
        return try response.items.map { try .init(from: $0) }
    }

    func getCommentHistory(
        type: GetContentFilter,
        page: Int?,
        cursor: String?,
        limit: Int
    ) async throws -> (comments: [Comment2Snapshot], cursor: String?) {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                guard let page else {
                    throw ApiClientError.featureUnsupported
                }

                let request = LemmyListCommentsRequest(
                    endpoint: .v3,
                    type_: .all,
                    sort: .new,
                    maxDepth: nil,
                    page: page,
                    limit: limit,
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
                return try (
                    comments: response.items.map { try .init(from: $0) },
                    cursor: response.nextPage
                )
            case .v4:
                switch type {
                case .saved:
                let request = LemmyListPersonSavedRequest(
                    type_: .comments,
                    searchTerm: nil,
                    pageCursor: cursor,
                    limit: limit
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try (
                    comments: response.items.compactMap(\.commentValue).map {
                        try .init(from: $0)
                    },
                    cursor: response.nextPage
                )
                default:
                let request = LemmyListPersonLikedRequest(
                    type_: .comments,
                    likeType: type == .upvoted ? .likedOnly : .dislikedOnly,
                    pageCursor: cursor,
                    limit: limit
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try (
                    comments: response.items.compactMap(\.commentValue).map {
                        try .init(from: $0)
                    },
                    cursor: response.nextPage
                )
                }
            }
        }
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
            createSortType: { _ in sort.v3PostApiType },
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
            createSortType: { _  in sort.v3ApiType },
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
        createSortType: @escaping (LemmyEndpointVersion) throws -> LemmySortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Comment2Snapshot] {
        let response = try await performingForEndpoint { endpoint in
            try LemmySearchRequest(
                endpoint: endpoint,
                q: query,
                communityId: communityId,
                communityName: nil,
                creatorId: creatorId,
                type_: .comments,
                sort: createSortType(endpoint),
                listingType: filter.apiType,
                page: page,
                limit: limit,
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
        return try response.comments.map { try .init(from: $0) }
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
    func getCommentVotes(
        id: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        let response = try await performingForEndpoint { endpoint in
            LemmyListCommentLikesRequest(
                endpoint: endpoint,
                commentId: id,
                page: page,
                limit: limit,
                pageCursor: nil
            )
        }
        return try response.items.map { try .init(from: $0) }
    }
}
