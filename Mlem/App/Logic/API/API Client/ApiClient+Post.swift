//
//  NewApiClient+Post.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

extension ApiClient: PostFeedProvider {
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        communityId: Int,
        sort: ApiSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> (posts: [Post2], cursor: String?) {
        let request = try GetPostsRequest(
            communityId: communityId,
            page: page,
            cursor: cursor,
            sort: sort,
            type: .all,
            limit: limit,
            savedOnly: savedOnly
        )
        let response = try await perform(request)
        let posts = response.posts.map { caches.post2.getModel(api: self, from: $0) }
        return (posts: posts, cursor: response.nextPage)
    }
    
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        feed: ApiListingType,
        sort: ApiSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> (posts: [Post2], cursor: String?) {
        let request = try GetPostsRequest(
            communityId: nil,
            page: page,
            cursor: cursor,
            sort: sort,
            type: feed,
            limit: limit,
            savedOnly: savedOnly
        )
        let response = try await perform(request)
        let posts = response.posts.map { caches.post2.getModel(api: self, from: $0) }
        return (posts: posts, cursor: response.nextPage)
    }
    
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation, semaphore: UInt?) async throws -> Post2 {
        let request = LikePostRequest(postId: id, score: score.rawValue)
        let response = try await perform(request)
        return caches.post2.getModel(api: self, from: response.postView, semaphore: semaphore)
    }
    
    @discardableResult
    func savePost(id: Int, save: Bool, semaphore: UInt?) async throws -> Post2 {
        let request = SavePostRequest(postId: id, save: save)
        let response = try await perform(request)
        return caches.post2.getModel(api: self, from: response.postView, semaphore: semaphore)
    }
}
