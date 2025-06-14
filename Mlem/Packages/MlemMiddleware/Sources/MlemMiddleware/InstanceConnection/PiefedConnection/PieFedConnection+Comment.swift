//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public extension PieFedConnection {
    func getComment(id: Int) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getComments(
        postId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getComments(
        parentId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
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
        throw ApiClientError.unsupportedLemmyVersion
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
        throw ApiClientError.unsupportedLemmyVersion
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
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func saveComment(id: Int, save: Bool) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func deleteComment(id: Int, delete: Bool) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> ReportSnapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func purgeComment(id: Int, reason: String?) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func removeComment(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Comment2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func getCommentVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
}
