//
//  ApiClient+Comment.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public extension ApiClient {
    func getComment(id: Int) async throws -> Comment2 {
        let request = GetCommentRequest(endpoint: .v3, id: id)
        let response = try await perform(request)
        return try await caches.comment2.getModel(api: self, from: .init(from: response.commentView))
    }
    
    func getComment(url: URL) async throws -> Comment2 {
        let request = ResolveObjectRequest(endpoint: .v3, q: url.absoluteString)
        do {
            if let response = try await perform(request).comment {
                return try await caches.comment2.getModel(api: self, from: .init(from: response))
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
        throw ApiClientError.noEntityFound
    }
    
    func getComments(
        postId: Int,
        sort: ApiCommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        let request = GetCommentsRequest(
            endpoint: .v3,
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
            dislikedOnly: filter == .downvoted,
            timeRangeSeconds: nil
        )
        let response = try await perform(request)
        return try await caches.comment2.getModels(
            api: self,
            from: response.comments.map { try .init(from: $0) }
        )
    }
    
    func getComments(
        parentId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        let request = GetCommentsRequest(
            endpoint: .v3,
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
            timeRangeSeconds: nil
        )
        let response = try await perform(request)
        return try await caches.comment2.getModels(api: self, from: response.comments.map { try .init(from: $0) })
    }
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ApiListingType = .all,
        sort: CommentSortType = .top(.allTime)
    ) async throws -> [Comment2] {
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
        filter: ApiListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Comment2] {
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
        filter: ApiListingType,
        legacySort: ApiSortType?,
        sort: ApiSearchSortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Comment2] {
        let endpointVersion = try await version.highestSupportedEndpointVersion
        let request = SearchRequest(
            endpoint: .v3,
            q: query,
            communityId: communityId,
            communityName: nil,
            creatorId: creatorId,
            type_: .comments,
            sort: .init(oldSortType: endpointVersion == .v3 ? legacySort : nil, newSortType: endpointVersion == .v4 ? sort : nil),
            listingType: filter,
            page: page,
            limit: limit,
            postTitleOnly: false,
            searchTerm: nil,
            timeRangeSeconds: timeRangeSeconds,
            titleOnly: nil,
            postUrlOnly: nil,
            likedOnly: nil,
            dislikedOnly: nil,
            pageCursor: nil,
            pageBack: nil
        )
        let response = try await perform(request)
        return try await caches.comment2.getModels(
            api: self,
            from: (response.comments ?? []).map { try .init(from: $0) }
        )
    }
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation, semaphore: UInt? = nil) async throws -> Comment2 {
        let request = CreateCommentLikeRequest(endpoint: .v3, commentId: id, score: score.rawValue)
        let response = try await perform(request)
        return try await caches.comment2.getModel(
            api: self,
            from: .init(from: response.commentView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func saveComment(id: Int, save: Bool, semaphore: UInt? = nil) async throws -> Comment2 {
        let request = SaveCommentRequest(endpoint: .v3, commentId: id, save: save)
        let response = try await perform(request)
        return try await caches.comment2.getModel(
            api: self,
            from: .init(from: response.commentView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func deleteComment(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Comment2 {
        let request = DeleteCommentRequest(endpoint: .v3, commentId: id, deleted: delete)
        let response = try await perform(request)
        return try await caches.comment2.getModel(
            api: self,
            from: .init(from: response.commentView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2 {
        let request = EditCommentRequest(
            endpoint: .v3,
            commentId: id,
            content: content,
            languageId: languageId,
            formId: nil
        )
        let response = try await perform(request)
        return try await caches.comment2.getModel(api: self, from: .init(from: response.commentView))
    }
    
    // There's also a `replyToPost` method in `ApiClient+Post` for creating a comment on a post
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int? = nil) async throws -> Comment2 {
        let request = CreateCommentRequest(
            endpoint: .v3,
            content: content,
            postId: postId,
            parentId: parentId,
            languageId: languageId,
            formId: nil
        )
        let response = try await perform(request)
        let comment = try await caches.comment2.getModel(api: self, from: .init(from: response.commentView))
        comment.getCachedInboxReply()?.setKnownReadState(newValue: true)
        return comment
    }
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> Report {
        let request = CreateCommentReportRequest(
            endpoint: .v3,
            commentId: id,
            reason: reason,
            violatesInstanceRules: nil
        )
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.report.getModel(
            api: self,
            from: .init(from: response.commentReportView),
            myPersonId: myPersonId
        )
    }
    
    func purgeComment(id: Int, reason: String?) async throws {
        let request = PurgeCommentRequest(endpoint: .v3, commentId: id, reason: reason)
        let response = try await perform(request)
        guard response.success else { throw ApiClientError.unsuccessful }
        caches.comment1.retrieveModel(cacheId: id)?.purged = true
    }
    
    @discardableResult
    func removeComment(
        id: Int,
        remove: Bool,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> Comment2 {
        let request = RemoveCommentRequest(endpoint: .v3, commentId: id, removed: remove, reason: reason)
        let response = try await perform(request)
        return try await caches.comment2.getModel(
            api: self,
            from: .init(from: response.commentView),
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
        let request = ListCommentLikesRequest(endpoint: .v3, commentId: id, page: page, limit: limit)
        let response = try await perform(request)
        return await caches.personVote.getModels(
            api: self,
            from: response.commentLikes,
            target: .comment(id: id),
            communityId: communityId
        )
    }
}
