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
        let response = try await performingForConnection { connection in
            try await connection.getPosts(
                communityId: communityId,
                sort: sort,
                page: page,
                cursor: cursor,
                limit: limit,
                filter: filter,
                showHidden: showHidden
            )
        }
        let posts = await caches.post2.getModels(
            api: self,
            from: response.posts
        )
        return (posts: posts, cursor: response.cursor)
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
        let response = try await performingForConnection { connection in
            try await connection.getPosts(
                feed: feed,
                sort: sort,
                page: page,
                cursor: cursor,
                limit: limit,
                filter: filter,
                showHidden: showHidden
            )
        }
        let posts = await caches.post2.getModels(
            api: self,
            from: response.posts
        )
        return (posts: posts, cursor: response.cursor)
    }
    
    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person3, posts: [Post2]) {
        let response = try await performingForConnection { connection in
            try await connection.getPosts(
                personId: personId,
                communityId: communityId,
                sort: sort,
                page: page,
                limit: limit,
                savedOnly: savedOnly
            )
        }
        return await (
            person: caches.person3.getModel(api: self, from: response.person),
            posts: caches.post2.getModels(api: self, from: response.posts)
        )
    }
        
    func getPost(id: Int) async throws -> Post3 {
        let response = try await performingForConnection { connection in
            try await connection.getPost(id: id)
        }
        return await caches.post3.getModel(api: self, from: response)
    }
    
    func getPost(url: URL) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.getPost(url: url)
        }
        return await caches.post2.getModel(api: self, from: response)
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
        let response = try await performingForConnection { connection in
            try await connection.searchPosts(
                query: query,
                page: page,
                limit: limit,
                communityId: communityId,
                creatorId: creatorId,
                filter: filter,
                sort: sort
            )
        }
        return await caches.post2.getModels(api: self, from: response)
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
        let response = try await performingForConnection { connection in
            try await connection.searchPosts(
                query: query,
                page: page,
                limit: limit,
                communityId: communityId,
                creatorId: creatorId,
                filter: filter,
                sort: sort
            )
        }
        return await caches.post2.getModels(api: self, from: response)
    }
    
    /// Mark the given post as read. Works on all versions.
    /// If `includeQueuedPosts` is set to `true`, any queued posts will be marked read as well.
    func markPostAsRead(
        id: Int,
        read: Bool = true,
        includeQueuedPosts: Bool = true,
        semaphore: UInt? = nil
    ) async throws {
        if read {
            // We *must* use `postIds` from 0.19.4 onwards. On 0.19.3 and below, either `postId` or `postIds` is allowed.
            try await markPostsAsRead(
                ids: [id],
                includeQueuedPosts: includeQueuedPosts,
                semaphore: semaphore
            )
        } else {
            try await performingForConnection { connection in
                try await connection.markPostAsRead(id: id, read: false)
                if let post = self.caches.post2.retrieveModel(cacheId: id) {
                    post.readManager.updateWithReceivedValue(read, semaphore: semaphore)
                }
            }
        }
    }
    
    /// Mark the given posts as read.
    /// Calling this will also mark any queued posts as read unless `includeQueuedPosts` is set to `false`.
    func markPostsAsRead(
        ids: Set<Int>,
        includeQueuedPosts: Bool = true,
        semaphore: UInt? = nil
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
            try await performingForConnection { connection in
                try await connection.markPostsAsRead(ids: idsToSend)
            }
            await markReadQueue.subtract(ids)
        } catch {
            await markReadQueue.union(markReadQueueCopy)
            throw error
        }
        Task { @MainActor in
            for post in idsToSend.compactMap({ caches.post2.retrieveModel(cacheId: $0) }) {
                post.readManager.updateWithReceivedValue(true, semaphore: semaphore)
                post.updateReadQueued(false)
            }
        }
    }
    
    func flushPostReadQueue() async throws {
        if await !markReadQueue.ids.isEmpty {
            try await markPostsAsRead(ids: [])
        }
    }
    
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation, semaphore: UInt? = nil) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.voteOnPost(id: id, score: score)
        }
        return await caches.post2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }

    @discardableResult
    func savePost(id: Int, save: Bool, semaphore: UInt? = nil) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.savePost(id: id, save: save)
        }
        return await caches.post2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func deletePost(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.deletePost(id: id, delete: delete)
        }
        return await caches.post2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    /// Added in 0.19.4
    func hidePost(
        id: Int,
        hide: Bool,
        semaphore: UInt? = nil
    ) async throws {
        try await performingForConnection { connection in
            try await connection.hidePost(id: id, hide: hide)
        }
        if let post = caches.post2.retrieveModel(cacheId: id) {
            post.hiddenManager.updateWithReceivedValue(hide, semaphore: semaphore)
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
        let response = try await performingForConnection { connection in
            try await connection.createPost(
                communityId: communityId,
                title: title,
                content: content,
                linkUrl: linkUrl,
                altText: altText,
                thumbnail: thumbnail,
                nsfw: nsfw,
                languageId: languageId
            )
        }
        return await caches.post2.getModel(api: self, from: response)
    }
    
    @discardableResult
    func editPost(
        id: Int,
        title: String,
        content: String? = nil,
        linkUrl: URL? = nil,
        altText: String? = nil,
        thumbnail: URL? = nil,
        nsfw: Bool,
        languageId: Int? = nil
    ) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.editPost(
                id: id,
                title: title,
                content: content,
                linkUrl: linkUrl,
                altText: altText,
                thumbnail: thumbnail,
                nsfw: nsfw,
                languageId: languageId
            )
        }
        return await caches.post2.getModel(api: self, from: response)
    }

    func replyToPost(id: Int, content: String, languageId: Int? = nil) async throws -> Comment2 {
        let response = try await performingForConnection { connection in
            try await connection.replyToPost(id: id, content: content, languageId: languageId)
        }
        return await caches.comment2.getModel(api: self, from: response)
    }
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> Report {
        let response = try await performingForConnection { connection in
            try await connection.reportPost(id: id, reason: reason)
        }
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: response,
            myPersonId: myPersonId
        )
    }
    
    func purgePost(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgePost(id: id, reason: reason)
        }
    }
    
    @discardableResult
    func removePost(
        id: Int,
        remove: Bool,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.removePost(id: id, remove: remove, reason: reason)
        }
        return await caches.post2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func pinPost(
        id: Int,
        pin: Bool,
        to target: PostFeatureType,
        semaphore: UInt? = nil
    ) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.pinPost(id: id, pin: pin, to: target)
        }
        return await caches.post2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func lockPost(
        id: Int,
        lock: Bool,
        semaphore: UInt? = nil
    ) async throws -> Post2 {
        let response = try await performingForConnection { connection in
            try await connection.lockPost(id: id, lock: lock)
        }
        return await caches.post2.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func getPostVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVote] {
        let response = try await performingForConnection { connection in
            try await connection.getPostVotes(
                id: id,
                communityId: communityId,
                page: page,
                limit: limit
            )
        }
        return await caches.personVote.getModels(
            api: self,
            from: response,
            target: .post(id: id),
            communityId: communityId
        )
    }
}
