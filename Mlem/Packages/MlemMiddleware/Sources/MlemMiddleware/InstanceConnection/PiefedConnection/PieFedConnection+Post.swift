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
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        if filter == .downvoted {
            throw ApiClientError.featureUnsupported
        }
        let page = try pageInfo.cursor.requirePageNumber
        let request = PieFedListPostsRequest(
            q: nil,
            sort: sort.pieFedSortType,
            type_: nil,
            communityName: nil,
            communityId: communityId,
            savedOnly: filter == .saved,
            personId: nil,
            limit: pageInfo.limit,
            page: page,
            likedOnly: filter == .upvoted,
            feedId: nil,
            topicId: nil,
            pageCursor: page,
            ignoreSticky: nil,
            nsfw: nil
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.posts.map { try .init(from: $0) }
        )
    }

    func getPosts(
        feed: ListingType,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        if filter == .downvoted || showHidden {
            throw ApiClientError.featureUnsupported
        }
        let page = try pageInfo.cursor.requirePageNumber
        let request = PieFedListPostsRequest(
            q: nil,
            sort: sort.pieFedSortType,
            type_: feed.pieFedListingType,
            communityName: nil,
            communityId: nil,
            savedOnly: filter == .saved,
            personId: nil,
            limit: pageInfo.limit,
            page: page,
            likedOnly: filter == .upvoted,
            feedId: nil,
            topicId: nil,
            pageCursor: page,
            ignoreSticky: nil,
            nsfw: nil
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.posts.map { try .init(from: $0) }
        )
    }

    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        pageInfo: PageInfo,
        sort: PostSortType = .new,
        savedOnly: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        throw ApiClientError.featureUnsupported
    }

    func getPostHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Post2Snapshot> {
        guard type != .downvoted else {
            throw ApiClientError.featureUnsupported
        }
        let page = try pageInfo.cursor.requirePageNumber
        let request = PieFedListPostsRequest(
            q: nil,
            sort: .new,
            type_: nil,
            communityName: nil,
            communityId: nil,
            savedOnly: type == .saved,
            personId: nil,
            limit: pageInfo.limit,
            page: page,
            likedOnly: type == .upvoted,
            feedId: nil,
            topicId: nil,
            pageCursor: page,
            ignoreSticky: nil,
            nsfw: nil
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.posts.map { try .init(from: $0) }
        )
    }

    func getPost(id: Int) async throws -> Post3Snapshot {
        let request = PieFedGetPostRequest(id: id, commentId: nil)
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func getPost(url: URL) async throws -> Post2Snapshot {
        let request = PieFedResolveObjectRequest(q: url.absoluteString)
        let response = try await perform(request)
        if let post = response.post {
            return try .init(from: post)
        }
        throw ApiClientError.noEntityFound
    }

    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchPosts(
        query: String,
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: PostSortType
    ) async throws -> PagedResponse<Post2Snapshot> {
        guard let sort = sort.pieFedSearchSortType else {
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
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            communityName: nil,
            communityId: communityId,
            minimumUpvotes: nil,
            nsfw: nil
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.posts.map { try .init(from: $0) }
        )
    }
    
    func markPostsAsRead(ids: Set<Int>, read: Bool) async throws {
        let request = PieFedMarkPostAsReadRequest(read: read, postId: nil, postIds: Array(ids))
        try await perform(request)
    }
    
    func markPostAsRead(id: Int, read: Bool) async throws {
        let request = PieFedMarkPostAsReadRequest(read: read, postId: id, postIds: nil)
        try await perform(request)
    }
    
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> Post2Snapshot {
        let request = PieFedLikePostRequest(
            postId: id,
            score: score.rawValue,
            private: nil,
            emoji: nil
        )
        async let response = perform(request)
        return try await .init(from: response.postView)
    }
    
    @discardableResult
    func savePost(id: Int, save: Bool) async throws -> Post2Snapshot {
        let request = PieFedSavePostRequest(postId: id, save: save)
        async let response = try await perform(request)
        return try await .init(from: response.postView)
    }
    
    @discardableResult
    func setPostNotificationsEnabled(id: Int, enabled: Bool) async throws -> Post2Snapshot {
        let request = PieFedSubscribePostRequest(postId: id, subscribe: enabled)
        let response = try await perform(request)
        return try .init(from: response.postView)
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
            body: content,
            url: linkUrl,
            nsfw: nsfw,
            languageId: languageId,
            altText: altText,
            aiGenerated: nil,
            event: nil,
            poll: nil,
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
            body: content,
            url: linkUrl,
            nsfw: nsfw,
            languageId: languageId,
            altText: altText,
            event: nil,
            poll: nil,
            tags: nil,
            flair: nil
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
        let request = PieFedCreatePostReportRequest(
            postId: id,
            reason: reason,
            description: nil,
            reportRemote: true
        )
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
    func setPostNsfw(id: Int, nsfw: Bool) async throws -> Post1Snapshot {
        let request = PieFedModerateCommunityPostNsfwRequest(postId: id, nsfwStatus: nsfw)
        let response = try await perform(request)
        return try .init(from: response.post)
    }

    @discardableResult
    func getPostVotes(
        id: Int,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVoteSnapshot> {
        let request = PieFedListPostLikesRequest(postId: id, page: try pageInfo.cursor.requirePageNumber, limit: pageInfo.limit)
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.postLikes.map { try .init(from: $0) }
        )
    }

    @discardableResult
    func voteInPoll(postId: Int, choiceIds: Set<Int>) async throws -> Post2Snapshot {
        let request = PieFedPollVoteRequest(postId: postId, choiceId: Array(choiceIds))
        let response = try await perform(request)
        return try .init(from: response.postView)
    }
}
