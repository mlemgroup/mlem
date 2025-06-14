//
//  ApiClient+Comment.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public extension ApiClient {
    func getComment(id: Int) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.getComment(id: id)
        }
        return await caches.comment2.getModel(api: self, from: response)
    }
    
    func getComment(url: URL) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.getComment(url: url)
        }
        return await caches.comment2.getModel(api: self, from: response)
    }
    
    func getComments(
        postId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        let response = try await performingForConnection { connection in
            try await connection.getComments(
                postId: postId,
                sort: sort,
                page: page,
                maxDepth: maxDepth,
                limit: limit,
                filter: filter
            )
        }
        return await caches.comment2.getModels(api: self, from: response)
    }
    
    func getComments(
        parentId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        let response = try await performingForConnection { connection in
            try await connection.getComments(
                parentId: parentId,
                sort: sort,
                page: page,
                maxDepth: maxDepth,
                limit: limit,
                filter: filter
            )
        }
        return await caches.comment2.getModels(api: self, from: response)
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
    ) async throws -> [Comment2] {
        let response = try await performingForConnection { connection in
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
        return await caches.comment2.getModels(api: self, from: response)
    }
    
    func searchComments(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Comment2] {
        let response = try await performingForConnection { connection in
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
        return await caches.comment2.getModels(api: self, from: response)
    }

    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation, semaphore: UInt? = nil) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.voteOnComment(id: id, score: score)
        }
        return await caches.comment2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func saveComment(id: Int, save: Bool, semaphore: UInt? = nil) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.saveComment(id: id, save: save)
        }
        return await caches.comment2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func deleteComment(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.deleteComment(id: id, delete: delete)
        }
        return await caches.comment2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.editComment(
                id: id,
                content: content,
                languageId: languageId
            )
        }
        return await caches.comment2.getModel(api: self, from: response)
    }
    
    // There's also a `replyToPost` method in `ApiClient+Post` for creating a comment on a post
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.replyToComment(
                postId: postId,
                parentId: parentId,
                content: content,
                languageId: languageId
            )
        }
        return await caches.comment2.getModel(api: self, from: response)
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> Report {
        let response = try await performingForConnection { connection in
            try await connection.reportComment(id: id, reason: reason)
        }
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: response,
            myPersonId: myPersonId
        )
    }
    
    func purgeComment(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgeComment(id: id, reason: reason)
        }
    }
    
    @discardableResult
    func removeComment(
        id: Int,
        remove: Bool,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.removeComment(id: id, remove: remove, reason: reason)
        }
        return await caches.comment2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func getCommentVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVote] {
        let response = try await performingForConnection { connection in
            try await connection.getCommentVotes(
                id: id,
                communityId: communityId,
                page: page,
                limit: limit
            )
        }
        return await caches.personVote.getModels(
            api: self,
            from: response,
            target: .comment(id: id),
            communityId: communityId
        )
    }
}
