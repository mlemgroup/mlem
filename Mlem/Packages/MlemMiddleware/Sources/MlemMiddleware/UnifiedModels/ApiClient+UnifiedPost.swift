//
//  ApiClient+UnifiedPost.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-03.
//

import Foundation

public extension ApiClient {
    // swiftlint:disable:next function_parameter_count
    func unifiedGetPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [UnifiedPostModel], cursor: String?) {
        let snapshots = try await repository.getPosts(
            communityId: communityId,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            filter: filter,
            showHidden: showHidden
        )
        let posts = await caches.post.getModels(
            api: self,
            from: snapshots.posts.map { .post2($0) }
        )
        return (posts: posts, cursor: snapshots.cursor)
    }
    
    // swiftlint:disable:next function_parameter_count
    func unifiedGetPosts(
        feed: ListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [UnifiedPostModel], cursor: String?) {
        let snapshots = try await repository.getPosts(
            feed: feed,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            filter: filter,
            showHidden: showHidden
        )
        let posts = await caches.post.getModels(
            api: self,
            from: snapshots.posts.map { .post2($0) }
        )
        return (posts: posts, cursor: snapshots.cursor)
    }
    
    func unifiedGetPosts(
        personId: Int,
        communityId: Int? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person3, posts: [UnifiedPostModel]) {
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
            posts: caches.post.getModels(api: self, from: snapshots.posts.map { .post2($0) })
        )
    }
    
    func unifiedGetPostHistory(
        type: GetContentFilter,
        page: Int?,
        cursor: String?,
        limit: Int
    ) async throws -> (posts: [UnifiedPostModel], cursor: String?) {
        let snapshots = try await repository.getPostHistory(
            type: type,
            page: page,
            cursor: cursor,
            limit: limit
        )
        let posts = await caches.post.getModels(
            api: self,
            from: snapshots.posts.map { .post2($0) }
        )
        return (posts: posts, cursor: snapshots.cursor)
    }
    
    func unifiedGetPost(id: Int) async throws -> UnifiedPostModel {
        let snapshot = try await repository.getPost(id: id)
        return await caches.post.getModel(api: self, from: .post3(snapshot))
    }
    
    func unifiedGetPost(url: URL) async throws -> UnifiedPostModel {
        let snapshot = try await repository.getPost(url: url)
        return await caches.post.getModel(api: self, from: .post2(snapshot))
    }
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func unifiedSearchPosts(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: PostSortType
    ) async throws -> [UnifiedPostModel] {
        let snapshots = try await repository.searchPosts(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        return await caches.post.getModels(api: self, from: snapshots.map { .post2($0) })
    }
    
    func unifiedSearchPosts(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: SearchSortType
    ) async throws -> [UnifiedPostModel] {
        let snapshots = try await repository.searchPosts(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            sort: sort
        )
        return await caches.post.getModels(api: self, from: snapshots.map { .post2($0) })
    }
    
    // TODO: NOW markPosetsAsRead
    // TODO: NOW flushPostReadQueue
    
    func unifiedCreatePost(
        communityId: Int,
        title: String,
        content: String? = nil,
        linkUrl: URL? = nil,
        altText: String? = nil,
        thumbnail: URL? = nil,
        nsfw: Bool,
        languageId: Int? = nil
    ) async throws -> UnifiedPostModel {
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
    
    // TODO: NOW move replyToPost either here or to comment section
    // TODO: NOW move reportPost here
    // TODO: NOW move purgePost here
    // TODO: NOW move getPostVotes here
}
