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
        postId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        try await performingForConnection { connection in
            try await connection.getComments(
                postId: postId,
                sort: sort,
                page: page,
                maxDepth: maxDepth,
                limit: limit,
                filter: filter
            )
        }
    }
    
    func getComments(
        parentId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2Snapshot] {
        try await performingForConnection { connection in
            try await connection.getComments(
                parentId: parentId,
                sort: sort,
                page: page,
                maxDepth: maxDepth,
                limit: limit,
                filter: filter
            )
        }
    }
    
    // TODO: Remove in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: CommentSortType = .top(.allTime)
    ) async throws -> [Comment2Snapshot] {
        try await performingForConnection { connection in
            try await connection.searchComments(
                query: query,
                page: page,
                limit: limit,
                communityId: communityId,
                creatorId: creatorId,
                filter: filter,
                sort: sort
            )
        }
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
        try await performingForConnection { connection in
            try await connection.searchComments(
                query: query,
                page: page,
                limit: limit,
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
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        try await performingForConnection { connection in
            try await connection.getCommentVotes(
                id: id,
                communityId: communityId,
                page: page,
                limit: limit
            )
        }
    }
}
