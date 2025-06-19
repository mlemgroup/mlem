//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public extension PieFedConnection {
    func getComment(id: Int) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    func getComments(
        postId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        guard let sort = sort.piefedSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: page,
            limit: limit,
            communityId: nil,
            communityName: nil,
            postId: postId,
            parentId: nil,
            savedOnly: filter == .saved,
            likedOnly: filter == .upvoted,
            dislikedOnly: filter == .downvoted
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
        guard let sort = sort.piefedSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetCommentsRequest(
            type_: .all,
            sort: sort,
            maxDepth: maxDepth,
            page: nil,
            limit: nil,
            communityId: nil,
            communityName: nil,
            postId: nil,
            parentId: parentId,
            savedOnly: filter == .saved,
            likedOnly: filter == .upvoted,
            dislikedOnly: filter == .downvoted
        )
        let response = try await perform(request)
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
        throw ApiClientError.featureUnsupported
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
        legacySort: ApiSortType?,
        sort: ApiSearchSortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Comment2Snapshot] {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func saveComment(id: Int, save: Bool) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func deleteComment(id: Int, delete: Bool) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> ReportSnapshot {
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func getCommentVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        throw ApiClientError.featureUnsupported
    }
}
