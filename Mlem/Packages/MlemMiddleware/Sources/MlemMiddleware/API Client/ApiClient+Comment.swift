//
//  ApiClient+Comment.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public extension ApiClient {
    func getComment(id: Int) async throws -> Comment2 {
        let snapshot = try await repository.getComment(id: id)
        return await caches.comment2.getModel(api: self, from: snapshot)
    }
    
    func getComment(url: URL) async throws -> Comment2 {
        let snapshot = try await repository.getComment(url: url)
        return await caches.comment2.getModel(api: self, from: snapshot)
    }
    
    func getComments(
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        let snapshots = try await repository.getComments(
            sort: sort,
            page: page,
            maxDepth: maxDepth,
            limit: limit,
            filter: filter
        )
        return await caches.comment2.getModels(api: self, from: snapshots)
    }
    
    func getComments(
        postId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        let snapshots = try await repository.getComments(
            postId: postId,
            sort: sort,
            page: page,
            maxDepth: maxDepth,
            limit: limit,
            filter: filter
        )
        return await caches.comment2.getModels(api: self, from: snapshots)
    }
    
    func getComments(
        parentId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        let snapshots = try await repository.getComments(
            parentId: parentId,
            sort: sort,
            page: page,
            maxDepth: maxDepth,
            limit: limit,
            filter: filter
        )
        return await caches.comment2.getModels(api: self, from: snapshots)
    }

    func getSavedComments(
        page: Int?,
        cursor: String?,
        limit: Int
    ) async throws -> (comments: [Comment2], cursor: String?) {
        let response = try await repository.getSavedComments(
            page: page,
            cursor: cursor,
            limit: limit
        )
        return try await (
            comments: caches.comment2.getModels(api: self, from: response.comments),
            cursor: response.cursor
        )
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
    ) async throws -> [Comment2] {
        let snapshots = try await repository.searchComments(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        return await caches.comment2.getModels(api: self, from: snapshots)
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
        let snapshots = try await repository.searchComments(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        return await caches.comment2.getModels(api: self, from: snapshots)
    }
    
    // TODO: UpdateQueue remove (currently needed for Reply)
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation, semaphore: UInt? = nil) async throws -> Comment2 {
        let snapshot = try await repository.voteOnComment(id: id, score: score)
        return await caches.comment2.getModel(
            api: self,
            from: snapshot,
            semaphore: semaphore
        )
    }
    
    // TODO: UpdateQueue remove (currently needed for Reply)
    @discardableResult
    func saveComment(id: Int, save: Bool, semaphore: UInt? = nil) async throws -> Comment2 {
        let snapshot = try await repository.saveComment(id: id, save: save)
        return await caches.comment2.getModel(
            api: self,
            from: snapshot,
            semaphore: semaphore
        )
    }
    
    // There's also a `replyToPost` method in `ApiClient+Post` for creating a comment on a post
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment2 {
        let snapshot = try await repository.replyToComment(
            postId: postId,
            parentId: parentId,
            content: content,
            languageId: languageId
        )
        return await caches.comment2.getModel(api: self, from: snapshot)
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> Report {
        let snapshot = try await repository.reportComment(id: id, reason: reason)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    func purgeComment(id: Int, reason: String?) async throws {
        try await repository.purgeComment(id: id, reason: reason)
    }
    
    @discardableResult
    func getCommentVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVote] {
        let snapshot = try await repository.getCommentVotes(
            id: id,
            page: page,
            limit: limit
        )
        return await caches.personVote.getModels(
            api: self,
            from: snapshot,
            target: .comment(id: id),
            communityId: communityId
        )
    }
}
