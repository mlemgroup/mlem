//
//  NewApiClient+Post.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public extension ApiClient {
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2], cursor: String?) {
        let snapshots = try await repository.getPosts(
            communityId: communityId,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            filter: filter,
            showHidden: showHidden
        )
        let posts = await caches.post2.getModels(
            api: self,
            from: snapshots.posts
        )
        return (posts: posts, cursor: snapshots.cursor)
    }
    
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        feed: ListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2], cursor: String?) {
        let snapshots = try await repository.getPosts(
            feed: feed,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            filter: filter,
            showHidden: showHidden
        )
        let posts = await caches.post2.getModels(
            api: self,
            from: snapshots.posts
        )
        return (posts: posts, cursor: snapshots.cursor)
    }
    
    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person3, posts: [Post2]) {
        let snapshots = try await repository.getPosts(
            personId: personId,
            communityId: communityId,
            sort: sort,
            page: page,
            limit: limit,
            savedOnly: savedOnly
        )
        return await (
            person: caches.person3.getModel(api: self, from: snapshots.person),
            posts: caches.post2.getModels(api: self, from: snapshots.posts)
        )
    }
    
    func getPost(id: Int) async throws -> Post3 {
        let snapshot = try await repository.getPost(id: id)
        return await caches.post3.getModel(api: self, from: snapshot)
    }
    
    func getPost(url: URL) async throws -> Post2 {
        let snapshot = try await repository.getPost(url: url)
        return await caches.post2.getModel(api: self, from: snapshot)
    }
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchPosts(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: PostSortType
    ) async throws -> [Post2] {
        let snapshots = try await repository.searchPosts(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        return await caches.post2.getModels(api: self, from: snapshots)
    }
    
    func searchPosts(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: SearchSortType
    ) async throws -> [Post2] {
        let snapshots = try await repository.searchPosts(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        return await caches.post2.getModels(api: self, from: snapshots)
    }
    
    /// Mark the given posts as read.
    /// Calling this will also mark any queued posts as read unless `includeQueuedPosts` is set to `false`.
    func markPostsAsRead(
        ids: Set<Int>,
        includeQueuedPosts: Bool = true
    ) async throws {
        let idsToSend: Set<Int>
        let markReadQueueCopy: Set<Int>
        if includeQueuedPosts {
            markReadQueueCopy = await markReadQueue.popAll()
            idsToSend = ids.union(markReadQueueCopy)
        } else {
            markReadQueueCopy = []
            idsToSend = ids
        }
        
        guard !idsToSend.isEmpty else { return }
        
        do {
            try await repository.markPostsAsRead(ids: idsToSend)
            await markReadQueue.subtract(ids)
        } catch {
            await markReadQueue.union(markReadQueueCopy)
            throw error
        }
        Task { @MainActor in
            for post in idsToSend.compactMap({ caches.post2.retrieveModel(cacheId: $0) }) {
                post.queuedMarkReadCompleted()
            }
        }
    }
    
    func flushPostReadQueue() async throws {
        if await !markReadQueue.ids.isEmpty {
            try await markPostsAsRead(ids: [])
        }
    }

    func createPost(
        communityId: Int,
        title: String,
        content: String? = nil,
        linkUrl: URL? = nil,
        altText: String? = nil,
        thumbnail: URL? = nil,
        nsfw: Bool,
        languageId: Int? = nil
    ) async throws -> Post2 {
        let snapshot = try await repository.createPost(
            communityId: communityId,
            title: title,
            content: content,
            linkUrl: linkUrl,
            altText: altText,
            thumbnail: thumbnail,
            nsfw: nsfw,
            languageId: languageId
        )
        return await caches.post2.getModel(api: self, from: snapshot)
    }
    
    func replyToPost(id: Int, content: String, languageId: Int? = nil) async throws -> Comment2 {
        let snapshot = try await repository.replyToPost(id: id, content: content, languageId: languageId)
        return await caches.comment2.getModel(api: self, from: snapshot)
    }
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> Report {
        let snapshot = try await repository.reportPost(id: id, reason: reason)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    func purgePost(id: Int, reason: String?) async throws {
        try await repository.purgePost(id: id, reason: reason)
    }
    
    @discardableResult
    func getPostVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVote] {
        let snapshot = try await repository.getPostVotes(
            id: id,
            page: page,
            limit: limit
        )
        return await caches.personVote.getModels(
            api: self,
            from: snapshot,
            target: .post(id: id),
            communityId: communityId
        )
    }
}
