//
//  ApiClient+Comment.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public extension ApiClient {
    func getComment(id: Int) async throws -> Comment {
        let snapshot = try await repository.getComment(id: id)
        return await caches.comment.getModel(api: self, from: .comment2(snapshot))
    }
    
    func getComment(url: URL) async throws -> Comment {
        let snapshot = try await repository.getComment(url: url)
        return await caches.comment.getModel(api: self, from: .comment2(snapshot))
    }
    
    func getComments(
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment> {
        let response = try await repository.getComments(
            pageInfo: pageInfo,
            sort: sort,
            maxDepth: maxDepth,
            filter: filter
        )
        let comments = await caches.comment.getModels(api: self, from: response.items.map { .comment2($0) })
        return .init(items: comments, nextLocation: response.nextLocation)
    }

    func getComments(
        postId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment> {
        let response = try await repository.getComments(
            postId: postId,
            pageInfo: pageInfo,
            sort: sort,
            maxDepth: maxDepth,
            filter: filter
        )
        let comments = await caches.comment.getModels(api: self, from: response.items.map { .comment2($0) })
        return .init(items: comments, nextLocation: response.nextLocation)
    }

    func getComments(
        parentId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int? = nil,
        filter: GetContentFilter? = nil
    ) async throws -> PagedResponse<Comment> {
        let response = try await repository.getComments(
            parentId: parentId,
            pageInfo: pageInfo,
            sort: sort,
            maxDepth: maxDepth,
            filter: filter
        )
        let comments = await caches.comment.getModels(api: self, from: response.items.map { .comment2($0) })
        return .init(items: comments, nextLocation: response.nextLocation)
    }

    func getCommentHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Comment> {
        let response = try await repository.getCommentHistory(
            type: type,
            pageInfo: pageInfo
        )
        let comments = await caches.comment.getModels(api: self, from: response.items.map { .comment2($0) })
        return .init(items: comments, nextLocation: response.nextLocation)
    }

    // TODO: Remove in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: CommentSortType = .top(.allTime)
    ) async throws -> PagedResponse<Comment> {
        let response = try await repository.searchComments(
            query: query,
            pageInfo: pageInfo,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        let comments = await caches.comment.getModels(api: self, from: response.items.map { .comment2($0) })
        return .init(items: comments, nextLocation: response.nextLocation)
    }
    
    // TODO: UpdateQueue remove (currently needed for Reply)
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation, semaphore: UInt? = nil) async throws -> Comment {
        let snapshot = try await repository.voteOnComment(id: id, score: score)
        return await caches.comment.getModel(
            api: self,
            from: .comment2(snapshot),
            semaphore: semaphore
        )
    }
    
    // TODO: UpdateQueue remove (currently needed for Reply)
    @discardableResult
    func saveComment(id: Int, save: Bool, semaphore: UInt? = nil) async throws -> Comment {
        let snapshot = try await repository.saveComment(id: id, save: save)
        return await caches.comment.getModel(
            api: self,
            from: .comment2(snapshot),
            semaphore: semaphore
        )
    }
    
    // There's also a `replyToPost` method in `ApiClient+Post` for creating a comment on a post
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment {
        let snapshot = try await repository.replyToComment(
            postId: postId,
            parentId: parentId,
            content: content,
            languageId: languageId
        )
        return await caches.comment.getModel(api: self, from: .comment2(snapshot))
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
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVote> {
        let response = try await repository.getCommentVotes(id: id, pageInfo: pageInfo)
        let votes = await caches.personVote.getModels(
            api: self,
            from: response.items,
            target: .comment(id: id),
            communityId: communityId
        )
        return .init(items: votes, nextLocation: response.nextLocation)
    }
}
