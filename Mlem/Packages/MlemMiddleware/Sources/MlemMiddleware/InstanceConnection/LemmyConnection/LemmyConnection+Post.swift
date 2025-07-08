//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation

public extension LemmyConnection {
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2Snapshot], cursor: String?) {
        let response = try await performingForEndpoint { endpoint in
            LemmyListPostsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.legacyApiSortType,
                page: cursor == nil ? page : nil,
                limit: limit,
                communityId: communityId,
                communityName: nil,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                pageCursor: cursor,
                showHidden: showHidden,
                showRead: nil,
                showNsfw: nil,
                timeRangeSeconds: nil,
                hideMedia: nil,
                markAsRead: nil,
                noCommentsOnly: nil,
                pageBack: nil
            )
        }
        return try (
            posts: response.posts.map { try .init(from: $0) },
            cursor: response.nextPage
        )
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
        let response = try await performingForEndpoint { endpoint in
            LemmyListPostsRequest(
                endpoint: endpoint,
                type_: feed.apiType,
                sort: sort.legacyApiSortType,
                page: cursor == nil ? page : nil,
                limit: limit,
                communityId: nil,
                communityName: nil,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                pageCursor: cursor,
                showHidden: showHidden,
                showRead: nil,
                showNsfw: nil,
                timeRangeSeconds: nil,
                hideMedia: nil,
                markAsRead: nil,
                noCommentsOnly: nil,
                pageBack: nil
            )
        }
        return try (
            posts: response.posts.map { try .init(from: $0) },
            cursor: response.nextPage
        )
    }

    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot]) {
        let response = try await performingForEndpoint { endpoint in
            LemmyReadPersonRequest(
                endpoint: endpoint,
                personId: personId,
                username: nil,
                sort: sort.legacyApiSortType,
                page: page,
                limit: limit,
                communityId: communityId,
                savedOnly: savedOnly
            )
        }
        return try (
            person: .init(from: response),
            posts: response.posts?.map { try .init(from: $0) } ?? []
        )
    }

    func getPost(id: Int) async throws -> Post3Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetPostRequest(
                endpoint: endpoint,
                id: id,
                commentId: nil
            )
        }
        return try .init(from: response)
    }
    
    func getPost(url: URL) async throws -> Post2Snapshot {
        do {
            let response = try await performingForEndpoint { endpoint in
                LemmyResolveObjectRequest(endpoint: endpoint, q: url.absoluteString)
            }
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
        try await searchPosts(
            query: query,
            page: page,
            limit: limit,
            communityId: communityId,
            creatorId: creatorId,
            filter: filter,
            legacySort: sort.legacyApiSortType,
            sort: sort.apiSearchSortType,
            timeRangeSeconds: nil
        )
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
        try await searchPosts(
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
        let response = try await performingForEndpoint { endpoint in
            LemmySearchRequest(
                endpoint: .v3,
                q: query,
                communityId: communityId,
                communityName: nil,
                creatorId: creatorId,
                type_: .posts,
                sort: .init(oldSortType: endpoint == .v3 ? legacySort : nil, newSortType: endpoint == .v4 ? sort : nil),
                listingType: filter.apiType,
                page: page,
                limit: limit,
                postTitleOnly: false,
                searchTerm: query,
                timeRangeSeconds: timeRangeSeconds,
                titleOnly: nil,
                postUrlOnly: nil,
                likedOnly: nil,
                dislikedOnly: nil,
                showNsfw: nil,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.posts?.map { try .init(from: $0) } ?? []
    }
    
    // Marking many posts as *unread* was possible in 0.19.0, but that capability was removed in 1.0.0
    func markPostsAsRead(ids: Set<Int>) async throws {
        guard !ids.isEmpty else { return }
        
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyMarkPostAsReadRequest(endpoint: .v3, postId: nil, postIds: Array(ids), read: true)
                try await perform(request)
            case .v4:
                let request = LemmyMarkPostsAsReadRequest(postIds: Array(ids))
                try await perform(request)
            }
        }
    }
    
    func markPostAsRead(id: Int, read: Bool) async throws {
        // Could we do something with the response here?
        _ = try await performingForEndpoint { endpoint in
            LemmyMarkPostAsReadRequest(
                endpoint: endpoint,
                postId: id,
                postIds: [id],
                read: read
            )
        }
    }
    
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> Post2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyLikePostRequest(
                endpoint: endpoint,
                postId: id,
                score: score.rawValue
            )
        }
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func savePost(id: Int, save: Bool) async throws -> Post2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmySavePostRequest(
                endpoint: endpoint,
                postId: id,
                save: save
            )
        }
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func deletePost(id: Int, delete: Bool) async throws -> Post2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyDeletePostRequest(
                endpoint: endpoint,
                postId: id,
                deleted: delete
            )
        }
        return try .init(from: response.postView)
    }
    
    // Marking many posts as hidden was possible in 0.19.0, but this was removed in 1.0.0
    func hidePost(id: Int, hide: Bool) async throws {
        // Could we do something with the response here?
        _ = try await performingForEndpoint { endpoint in
            LemmyHidePostRequest(
                endpoint: endpoint,
                postIds: [id],
                hide: hide,
                postId: id
            )
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
    ) async throws -> Post2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyCreatePostRequest(
                endpoint: endpoint,
                name: title,
                communityId: communityId,
                url: linkUrl,
                body: content,
                honeypot: nil,
                nsfw: nsfw,
                languageId: languageId,
                altText: altText,
                customThumbnail: thumbnail?.absoluteString,
                tags: nil,
                scheduledPublishTime: nil
            )
        }
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
        let response = try await performingForEndpoint { endpoint in
            LemmyUpdatePostRequest(
                endpoint: endpoint,
                postId: id,
                name: title,
                url: linkUrl,
                body: content,
                nsfw: nsfw,
                languageId: languageId,
                altText: altText,
                customThumbnail: thumbnail?.absoluteString,
                scheduledPublishTime: nil,
                tags: nil
            )
        }
        return try .init(from: response.postView)
    }
    
    func replyToPost(
        id: Int,
        content: String,
        languageId: Int? = nil
    ) async throws -> Comment2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyCreateCommentRequest(
                endpoint: endpoint,
                content: content,
                postId: id,
                parentId: nil,
                languageId: languageId
            )
        }
        return try .init(from: response.commentView)
    }
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyCreatePostReportRequest(
                endpoint: endpoint,
                postId: id,
                reason: reason,
                violatesInstanceRules: nil
            )
        }
        return try .init(from: response.postReportView)
    }
    
    func purgePost(id: Int, reason: String?) async throws {
        let response = try await performingForEndpoint { endpoint in
            LemmyPurgePostRequest(endpoint: endpoint, postId: id, reason: reason)
        }
        guard response.success else { throw ApiClientError.unsuccessful }
    }
    
    @discardableResult
    func removePost(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Post2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyRemovePostRequest(
                endpoint: endpoint,
                postId: id,
                removed: remove,
                reason: reason
            )
        }
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func pinPost(
        id: Int,
        pin: Bool,
        to target: PostFeatureType
    ) async throws -> Post2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyFeaturePostRequest(
                endpoint: endpoint,
                postId: id,
                featured: pin,
                featureType: target.apiType
            )
        }
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func lockPost(id: Int, lock: Bool) async throws -> Post2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyLockPostRequest(
                endpoint: endpoint,
                postId: id,
                locked: lock,
                reason: nil
            )
        }
        return try .init(from: response.postView)
    }
    
    @discardableResult
    func getPostVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        let response = try await performingForEndpoint { endpoint in
            LemmyListPostLikesRequest(
                endpoint: endpoint,
                postId: id,
                page: page,
                limit: limit,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.postLikes.map { try .init(from: $0) }
    }
}
