//
//  ApiRepository+Comment.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-02.
//

import Foundation

extension ApiRepository {
    func getComment(id: Int) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.getComment(id: id)
        }
    }
    
    func getComment(url: URL) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.getComment(url: url)
        }
    }
    
    func getComments(
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getComments(
                pageInfo: pageInfo,
                sort: sort,
                maxDepth: maxDepth,
                filter: filter
            )
        }
    }
    
    func getComments(
        postId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getComments(
                postId: postId,
                pageInfo: pageInfo,
                sort: sort,
                maxDepth: maxDepth,
                filter: filter
            )
        }
    }
    
    func getComments(
        parentId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getComments(
                parentId: parentId,
                pageInfo: pageInfo,
                sort: sort,
                maxDepth: maxDepth,
                filter: filter
            )
        }
    }

    func getCommentHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Comment2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getCommentHistory(
                type: type,
                pageInfo: pageInfo
            )
        }
    }
    
    // TODO: Remove in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: CommentSortType = .top(.allTime)
    ) async throws -> PagedResponse<Comment2Snapshot> {
        try await performingForConnection { connection in
            try await connection.searchComments(
                query: query,
                pageInfo: pageInfo,
                communityId: communityId,
                creatorId: creatorId,
                filter: filter,
                sort: sort
            )
        }
    }
    
    func voteOnComment(id: Int, score: ScoringOperation, semaphore: UInt? = nil) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.voteOnComment(id: id, score: score)
        }
    }
    
    func saveComment(id: Int, save: Bool, semaphore: UInt? = nil) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.saveComment(id: id, save: save)
        }
    }
    
    func setCommentNotificationsEnabled(id: Int, enabled: Bool, semaphore: UInt? = nil) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.setCommentNotificationsEnabled(id: id, enabled: enabled)
        }
    }
    
    func deleteComment(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.deleteComment(id: id, delete: delete)
        }
    }
    
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.editComment(
                id: id,
                content: content,
                languageId: languageId
            )
        }
    }
    
    // There's also a `replyToPost` method in `ApiRepository+Post` for creating a comment on a post
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.replyToComment(
                postId: postId,
                parentId: parentId,
                content: content,
                languageId: languageId
            )
        }
    }
    
    func reportComment(id: Int, reason: String) async throws -> ReportSnapshot {
        try await performingForConnection { connection in
            try await connection.reportComment(id: id, reason: reason)
        }
    }
    
    func purgeComment(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgeComment(id: id, reason: reason)
        }
    }
    
    func removeComment(
        id: Int,
        remove: Bool,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.removeComment(id: id, remove: remove, reason: reason)
        }
    }
    
    func getCommentVotes(
        id: Int,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVoteSnapshot> {
        try await performingForConnection { connection in
            try await connection.getCommentVotes(id: id, pageInfo: pageInfo)
        }
    }
}
