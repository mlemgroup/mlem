//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation

internal extension LemmyConnection {
    func getPosts(
        communityId: Int,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            try LemmyListPostsRequest(
                endpoint: endpoint,
                type_: .all,
                sort: sort.apiType(for: endpoint),
                page: pageInfo.cursor.pageNumber,
                limit: pageInfo.limit,
                communityId: communityId,
                communityName: nil,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                pageCursor: pageInfo.cursor.cursorString,
                showHidden: showHidden,
                showRead: nil,
                showNsfw: nil,
                timeRangeSeconds: sort.timeRangeSeconds,
                creatorId: nil,
                creatorUsername: nil,
                multiCommunityId: nil,
                multiCommunityName: nil,
                hideMedia: nil,
                markAsRead: nil,
                noCommentsOnly: nil,
                searchTerm: nil,
                searchTitleOnly: nil,
                searchUrlOnly: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.items.map { try .init(from: $0) },
            nextCursor: response.nextPage
        )
    }
    
    func getPosts(
        feed: ListingType,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            try LemmyListPostsRequest(
                endpoint: endpoint,
                type_: feed.apiType,
                sort: sort.apiType(for: endpoint),
                page: pageInfo.cursor.pageNumber,
                limit: pageInfo.limit,
                communityId: nil,
                communityName: nil,
                savedOnly: filter == .saved,
                likedOnly: filter == .upvoted,
                dislikedOnly: filter == .downvoted,
                pageCursor: pageInfo.cursor.cursorString,
                showHidden: showHidden,
                showRead: nil,
                showNsfw: nil,
                timeRangeSeconds: sort.timeRangeSeconds,
                creatorId: nil,
                creatorUsername: nil,
                multiCommunityId: nil,
                multiCommunityName: nil,
                hideMedia: nil,
                markAsRead: nil,
                noCommentsOnly: nil,
                searchTerm: nil,
                searchTitleOnly: nil,
                searchUrlOnly: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.items.map { try .init(from: $0) },
            nextCursor: response.nextPage
        )
    }

    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        pageInfo: PageInfo,
        sort: PostSortType = .new,
        savedOnly: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            if endpoint == .v4 {
                // TODO
                throw ApiClientError.featureUnsupported
            }
            return LemmyReadPersonRequest(
                endpoint: endpoint,
                personId: personId,
                username: nil,
                sort: sort.v3ApiType,
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                communityId: communityId,
                savedOnly: savedOnly
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.posts?.map { try .init(from: $0) } ?? [],
            nextCursor: nil
        )
    }

    func getPostHistory(type: GetContentFilter, pageInfo: PageInfo) async throws -> PagedResponse<Post2Snapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                // Cursors are supported on v3, but are super slow when
                // querying saved posts. For that reason, we're considering them
                // unsupported and requiring a page number instead.
                // See LemmyNet/lemmy#6171

                let page = try pageInfo.cursor.requirePageNumber

                let request = LemmyListPostsRequest(
                    endpoint: .v3,
                    type_: .all,
                    sort: .old(.new),
                    page: page,
                    limit: pageInfo.limit,
                    communityId: nil,
                    communityName: nil,
                    savedOnly: type == .saved,
                    likedOnly: type == .upvoted,
                    dislikedOnly: type == .downvoted,
                    pageCursor: nil,
                    showHidden: false,
                    showRead: nil,
                    showNsfw: nil,
                    timeRangeSeconds: nil,
                    creatorId: nil,
                    creatorUsername: nil,
                    multiCommunityId: nil,
                    multiCommunityName: nil,
                    hideMedia: nil,
                    markAsRead: nil,
                    noCommentsOnly: nil,
                    searchTerm: nil,
                    searchTitleOnly: nil,
                    searchUrlOnly: nil
                )
                let response = try await self.perform(request, endpoint: .v3)        
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.items.map { try .init(from: $0) },
                    // Cursor intentionally omitted here. See comment above
                    nextCursor: nil
                )

            case .v4:
                let response = try await self.v4GetPostHistory(type: type, pageInfo: pageInfo)
                return try .init(from: response.toPostsResponse()) { try .init(from: $0) }
            }
        }
    }

    private func v4GetPostHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> LemmyPagedResponse<LemmyPostCommentCombinedView> {
        let cursorString = try pageInfo.cursor.requireCursorString

        switch type {
        case .saved:
            let request = LemmyListPersonSavedRequest(
                type_: .all,
                searchTerm: nil,
                pageCursor: cursorString,
                limit: pageInfo.limit
            )
            return try await self.perform(request, endpoint: .v4)
        case .upvoted, .downvoted:
            let request = LemmyListPersonLikedRequest(
                type_: .all,
                likeType: type == .upvoted ? .likedOnly : .dislikedOnly,
                pageCursor: cursorString,
                limit: pageInfo.limit
            )
            return try await self.perform(request, endpoint: .v4)
        }
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
        let result = try await resolve(url: url)
        switch result {
        case let .post(post):
            return post
        default:
            throw ApiClientError.noEntityFound
        }
    }
    
    func searchPosts(
        query: String,
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: PostSortType
    ) async throws -> PagedResponse<Post2Snapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmySearchRequest(
                endpoint: endpoint,
                q: query,
                communityId: communityId,
                communityName: nil,
                creatorId: creatorId,
                type_: .posts,
                sort: sort.v3ApiType,
                listingType: filter.apiType,
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                postTitleOnly: false,
                searchTerm: query,
                creatorUsername: nil,
                timeRangeSeconds: nil,
                titleOnly: nil,
                postUrlOnly: nil,
                showNsfw: nil,
                pageCursor: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.posts.map { try .init(from: $0) },
            nextCursor: nil
        )
    }
    
    func markPostsAsRead(ids: Set<Int>, read: Bool) async throws {
        guard !ids.isEmpty else { return }
        
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyMarkPostAsReadRequest(endpoint: .v3, postId: nil, postIds: Array(ids), read: read)
                try await self.perform(request, endpoint: .v3)
            case .v4:
                let request = LemmyMarkPostsAsReadRequest(postIds: Array(ids), read: read)
                try await self.perform(request, endpoint: .v4)
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
                score: score.rawValue,
                isUpvote: score.booleanValue
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
        return try .init(from: response.postView, overrideRead: true)
    }
    
    @discardableResult
    func setPostNotificationsEnabled(id: Int, enabled: Bool) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
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
                scheduledPublishTimeAt: nil
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
            LemmyEditPostRequest(
                endpoint: endpoint,
                postId: id,
                name: title,
                url: linkUrl,
                body: content,
                nsfw: nsfw,
                languageId: languageId,
                altText: altText,
                customThumbnail: thumbnail?.absoluteString,
                scheduledPublishTimeAt: nil,
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
                reason: reason,
                removeChildren: nil
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
    func setPostNsfw(id: Int, nsfw: Bool) async throws -> Post1Snapshot {
        let response = try await performingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                throw ApiClientError.featureUnsupported
            case .v4:
                return LemmyModEditPostRequest(postId: id, nsfw: nsfw, tags: nil)
            }
        }
        return try .init(from: response.postView.post)
    }

    @discardableResult
    func getPostVotes(id: Int, pageInfo: PageInfo) async throws -> PagedResponse<PersonVoteSnapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmyListPostLikesRequest(
                endpoint: endpoint,
                postId: id,
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                pageCursor: nil
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: response.items.map { try .init(from: $0) },
            nextCursor: nil
        )
    }

    @discardableResult
    func voteInPoll(postId: Int, choiceIds: Set<Int>) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
    }
}
