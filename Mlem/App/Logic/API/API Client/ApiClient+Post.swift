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
        print("REQUEST", feed, sort, endpointUrl, token)
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
        print("RESPONSE", response.posts.first?.post.name)
        let posts = response.posts.map { caches.post2.getModel(api: self, from: $0) }
        return (posts: posts, cursor: response.nextPage)
    }
    
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation, semaphore: Int?) async throws -> Post2 {
        let request = LikePostRequest(postId: id, score: score.rawValue)
        let response = try await perform(request)
        
        if let semaphore, let existing = caches.post2.retrieveModel(cacheId: response.postView.cacheId) {
            let newVotes: VotesModel = .init(
                from: response.postView.counts,
                myVote: .guaranteedInit(from: response.postView.myVote)
            )
            if existing.votesManager.finishOperation(semaphore: semaphore, with: newVotes) {
                return caches.post2.getModel(api: self, from: response.postView)
            } else {
                return existing
            }
        } else {
            return caches.post2.getModel(api: self, from: response.postView)
        }
    }
}
