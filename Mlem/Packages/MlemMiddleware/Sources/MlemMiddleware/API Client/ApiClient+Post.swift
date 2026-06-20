//
//  NewApiClient+Post.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public extension ApiClient {
    func getPosts(
        communityId: Int,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post> {
        let response = try await repository.getPosts(
            communityId: communityId,
            pageInfo: pageInfo,
            sort: sort,
            filter: filter,
            showHidden: showHidden
        )
        let posts = await caches.post.getModels(
            api: self,
            from: response.items.map { .post2($0) }
        )
        return .init(items: posts, nextLocation: response.nextLocation)
    }

    func getPosts(
        feed: ListingType,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post> {
        let response = try await repository.getPosts(
            feed: feed,
            pageInfo: pageInfo,
            sort: sort,
            filter: filter,
            showHidden: showHidden
        )
        let posts = await caches.post.getModels(
            api: self,
            from: response.items.map { .post2($0) }
        )
        return .init(items: posts, nextLocation: response.nextLocation)
    }

    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        pageInfo: PageInfo,
        sort: PostSortType = .new,
        savedOnly: Bool = false
    ) async throws -> PagedResponse<Post> {
        let response = try await repository.getPosts(
            personId: personId,
            communityId: communityId,
            pageInfo: pageInfo,
            sort: sort,
            savedOnly: savedOnly
        )
        let posts = await caches.post.getModels(
            api: self,
            from: response.items.map { .post2($0) }
        )
        return .init(items: posts, nextLocation: response.nextLocation)
    }

    func getPostHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Post> {
        let response = try await repository.getPostHistory(
            type: type,
            pageInfo: pageInfo
        )
        let posts = await caches.post.getModels(
            api: self,
            from: response.items.map { .post2($0) }
        )
        return .init(items: posts, nextLocation: response.nextLocation)
    }
    
    func getPost(id: Int) async throws -> Post {
        let snapshot = try await repository.getPost(id: id)
        return await caches.post.getModel(api: self, from: .post3(snapshot))
    }
    
    func getPost(url: URL) async throws -> Post {
        let snapshot = try await repository.getPost(url: url)
        return await caches.post.getModel(api: self, from: .post2(snapshot))
    }
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchPosts(
        query: String,
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: PostSortType
    ) async throws -> PagedResponse<Post> {
        let response = try await repository.searchPosts(
            query: query,
            pageInfo: pageInfo,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        let posts = await caches.post.getModels(api: self, from: response.items.map { .post2($0) })
        return .init(items: posts, nextLocation: response.nextLocation)
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
            for post in idsToSend.compactMap({ caches.post.retrieveModel(cacheId: $0) }) {
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
    ) async throws -> Post {
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
        return await caches.post.getModel(api: self, from: .post2(snapshot))
    }
    
    func replyToPost(id: Int, content: String, languageId: Int? = nil) async throws -> Comment {
        let snapshot = try await repository.replyToPost(id: id, content: content, languageId: languageId)
        return await caches.comment.getModel(api: self, from: .comment2(snapshot))
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
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVote> {
        let response = try await repository.getPostVotes(id: id, pageInfo: pageInfo)
        let votes = await caches.personVote.getModels(
            api: self,
            from: response.items,
            target: .post(id: id),
            communityId: communityId
        )
        return .init(items: votes, nextLocation: response.nextLocation)
    }
}
