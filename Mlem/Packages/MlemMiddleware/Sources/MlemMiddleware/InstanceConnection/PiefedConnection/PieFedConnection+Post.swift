//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation

public extension PieFedConnection {
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2Snapshot], cursor: String?) {
        if filter == .downvoted {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedListPostsRequest(
            type_: nil,
            sort: sort.pieFedSortType,
            pageCursor: page,
            limit: limit,
            communityId: communityId,
            personId: nil,
            communityName: nil,
            likedOnly: filter == .upvoted,
            savedOnly: filter == .saved,
            q: nil,
            page: page,
            feedId: nil,
            topicId: nil
        )
        let response = try await perform(request)
        let posts: [Post2Snapshot] = try response.posts.map { try .init(from: $0) }
        return (posts: posts, cursor: nil)
    }
    
    func getPosts(
        feed: ListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2Snapshot], cursor: String?) {
        if filter == .downvoted || showHidden {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedListPostsRequest(
            type_: feed.pieFedListingType,
            sort: sort.pieFedSortType,
            pageCursor: page,
            limit: limit,
            communityId: nil,
            personId: nil,
            communityName: nil,
            likedOnly: filter == .upvoted,
            savedOnly: filter == .saved,
            q: nil,
            page: page,
            feedId: nil,
            topicId: nil
        )
        let response = try await perform(request)
        let posts: [Post2Snapshot] = try response.posts.map { try .init(from: $0) }
        return (posts: posts, cursor: nil)
    }

    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot]) {
        throw ApiClientError.featureUnsupported
    }

    func getPost(id: Int) async throws -> Post3Snapshot {
        let request = PieFedGetPostRequest(id: id, commentId: nil)
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func getPost(url: URL) async throws -> Post2Snapshot {
        do {
            let request = PieFedResolveObjectRequest(q: url.absoluteString)
            let response = try await perform(request)
            if let post = response.post {
                return try .init(from: post)
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
        throw ApiClientError.noEntityFound
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
    ) async throws -> [Post2Snapshot] {
        guard let sort = sort.pieFedSortType else {
            throw ApiClientError.featureUnsupported
        }
        if communityId != nil || creatorId != nil {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedSearchRequest(
            q: query,
            type_: .posts,
            sort: sort,
            listingType: filter.pieFedListingType,
            page: page,
            limit: limit,
            communityName: nil,
            communityId: communityId
        )
        let response = try await perform(request)
        return try response.posts.map { try .init(from: $0) }
    }
    
    func searchPosts(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: SearchSortType
    ) async throws -> [Post2Snapshot] {
        throw ApiClientError.featureUnsupported
    }
    
    private func searchPosts(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        legacySort: LemmySortType?,
        sort: LemmySearchSortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Post2Snapshot] {
        throw ApiClientError.featureUnsupported
    }
    
    func markPostsAsRead(ids: Set<Int>) async throws {
        let request = PieFedMarkPostAsReadRequest(postIds: Array(ids), postId: nil, read: true)
        try await perform(request)
    }
    
    func markPostAsRead(id: Int, read: Bool) async throws {
        let request = PieFedMarkPostAsReadRequest(postIds: nil, postId: id, read: read)
        try await perform(request)
    }
    
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> Post2Snapshot {
        let request = PieFedLikePostRequest(postId: id, score: score.rawValue, private: nil)
        async let response = perform(request)
        if !supports(.autoMarkPostReadOnInteract, defaultValue: false) {
            try await markPostAsRead(id: id, read: true)
            return try await .init(from: response.postView, overrideRead: true)
        }
        return try await .init(from: response.postView)
    }
    
    @discardableResult
    func savePost(id: Int, save: Bool) async throws -> Post2Snapshot {
        let request = PieFedSavePostRequest(postId: id, save: save)
        async let response = try await perform(request)
        if !supports(.autoMarkPostReadOnInteract, defaultValue: false) {
            try await markPostAsRead(id: id, read: true)
            return try await .init(from: response.postView, overrideRead: true)
        }
        return try await .init(from: response.postView)
    }
    
    @discardableResult
    func deletePost(id: Int, delete: Bool) async throws -> Post2Snapshot {
        let request = PieFedDeletePostRequest(postId: id, deleted: delete)
        let response = try await perform(request)
        return try .init(from: response.postView)
    }
    
    func hidePost(id: Int, hide: Bool) async throws {
        throw ApiClientError.featureUnsupported
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
    ) async throws -> Post2Snapshot {
        if thumbnail != nil || altText != nil {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedCreatePostRequest(
            title: title,
            communityId: communityId,
            url: linkUrl,
            body: content,
            nsfw: nsfw,
            languageId: languageId
        )
        let response = try await perform(request)
        return try .init(from: response.postView)
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
    ) async throws -> Post2Snapshot {
        if thumbnail != nil || altText != nil {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedEditPostRequest(
            postId: id,
            title: title,
            url: linkUrl,
            body: content,
            nsfw: nsfw,
            languageId: languageId
        )
        let response = try await perform(request)
        return try .init(from: response.postView)
    }
    
    func replyToPost(
        id: Int,
        content: String,
        languageId: Int? = nil
    ) async throws -> Comment2Snapshot {
        let request = PieFedCreateCommentRequest(
            body: content,
            postId: id,
            parentId: nil,
            languageId: languageId
        )
        let response = try await perform(request)
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> ReportSnapshot {
        let request = PieFedCreatePostReportRequest(postId: id, reason: reason)
        let response = try await perform(request)
        return try .init(from: response.postReportView)
    }
    
    func purgePost(id: Int, reason: String?) async throws {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func removePost(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Post2Snapshot {
        let request = PieFedRemovePostRequest(postId: id, removed: remove, reason: reason)
        let response = try await perform(request)
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func pinPost(
        id: Int,
        pin: Bool,
        to target: PostFeatureType
    ) async throws -> Post2Snapshot {
        let request = PieFedFeaturePostRequest(
            postId: id,
            featured: pin,
            featureType: target.piefedPostFeatureType
        )
        let response = try await perform(request)
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func lockPost(id: Int, lock: Bool) async throws -> Post2Snapshot {
        let request = PieFedLockPostRequest(postId: id, locked: lock)
        let response = try await perform(request)
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func getPostVotes(
        id: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        let request = PieFedListPostLikesRequest(postId: id, page: page, limit: limit)
        let response = try await perform(request)
        return try response.postLikes.map { try .init(from: $0) }
    }
}
