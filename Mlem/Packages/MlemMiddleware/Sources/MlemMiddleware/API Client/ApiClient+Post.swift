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
        let request = GetPostsRequest(
            endpoint: .v3,
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
            readOnly: nil,
            hideMedia: nil,
            markAsRead: nil,
            noCommentsOnly: nil,
            pageBack: nil
        )
        let response = try await perform(request)
        let posts = try await caches.post2.getModels(
            api: self,
            from: response.posts.map { try .init(from: $0) }
        )
        return (posts: posts, cursor: response.nextPage)
    }

    // swiftlint:disable:next function_parameter_count
    func getPosts(
        feed: ApiListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2], cursor: String?) {
        let request = GetPostsRequest(
            endpoint: .v3,
            type_: feed,
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
            readOnly: nil,
            hideMedia: nil,
            markAsRead: nil,
            noCommentsOnly: nil,
            pageBack: nil
        )
        let response = try await perform(request)
        let posts = try await caches.post2.getModels(
            api: self,
            from: response.posts.map { try .init(from: $0) }
        )
        return (posts: posts, cursor: response.nextPage)
    }
    
    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person3, posts: [Post2]) {
        let request = GetPersonDetailsRequest(
            endpoint: .v3,
            personId: personId,
            username: nil,
            sort: sort.legacyApiSortType,
            page: page,
            limit: limit,
            communityId: communityId,
            savedOnly: savedOnly
        )
        let response = try await perform(request)
        return try await (
            person: caches.person3.getModel(
                api: self,
                from: .init(from: response)
            ),
            posts: caches.post2.getModels(
                api: self,
                from: response.posts?.map { try .init(from: $0) } ?? []
            )
        )
    }
        
    func getPost(id: Int) async throws -> Post3 {
        let request = GetPostRequest(endpoint: .v3, id: id, commentId: nil)
        let response = try await perform(request)
        return try await caches.post3.getModel(
            api: self,
            from: .init(from: response)
        )
    }
    
    func getPost(url: URL) async throws -> Post2 {
        let request = ResolveObjectRequest(endpoint: .v3, q: url.absoluteString)
        do {
            if let response = try await perform(request).post {
                return try await caches.post2.getModel(
                    api: self,
                    from: .init(from: response)
                )
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
        filter: ApiListingType = .all,
        sort: PostSortType
    ) async throws -> [Post2] {
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
        filter: ApiListingType = .all,
        sort: SearchSortType
    ) async throws -> [Post2] {
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
        filter: ApiListingType,
        legacySort: ApiSortType?,
        sort: ApiSearchSortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Post2] {
        let endpointVersion = try await version.highestSupportedEndpointVersion
        let request = SearchRequest(
            endpoint: .v3,
            q: query,
            communityId: communityId,
            communityName: nil,
            creatorId: creatorId,
            type_: .posts,
            sort: .init(oldSortType: endpointVersion == .v3 ? legacySort : nil, newSortType: endpointVersion == .v4 ? sort : nil),
            listingType: filter,
            page: page,
            limit: limit,
            postTitleOnly: false,
            searchTerm: query,
            timeRangeSeconds: timeRangeSeconds,
            titleOnly: nil,
            postUrlOnly: nil,
            likedOnly: nil,
            dislikedOnly: nil,
            pageCursor: nil,
            pageBack: nil
        )
        let response = try await perform(request)
        return try await caches.post2.getModels(
            api: self,
            from: response.posts?.map { try .init(from: $0) } ?? []
        )
    }
    
    /// Mark the given post as read. Works on all versions.
    /// On v0.19.0 and above, if `includeQueuedPosts` is set to `true`, any queued posts will be marked read as well.
    func markPostAsRead(
        id: Int,
        read: Bool = true,
        includeQueuedPosts: Bool = true,
        semaphore: UInt? = nil
    ) async throws {
        // We *must* use `postId` in 0.18 versions, and we *must* use `postIds` from 0.19.4 onwards.
        // On versions 0.19.0 to 0.19.3, either parameter is allowed.
        let request: MarkPostAsReadRequest
        if try await supports(.batchMarkRead) {
            try await markPostsAsRead(
                ids: [id],
                read: read,
                includeQueuedPosts: includeQueuedPosts,
                semaphore: semaphore
            )
        } else {
            request = MarkPostAsReadRequest(endpoint: .v3, postId: id, read: read, postIds: nil)
            let response = try await perform(request)
            switch response {
            case let .apiSuccessResponse(response):
                if !response.success {
                    throw ApiClientError.unsuccessful
                }
            default:
                break
            }
            await markReadQueue.remove(id)
            Task { @MainActor in
                if let post = caches.post2.retrieveModel(cacheId: id) {
                    post.readManager.updateWithReceivedValue(read, semaphore: semaphore)
                    post.updateReadQueued(false)
                }
            }
        }
    }
    
    /// Mark the given posts as read. Only works on v0.19.0 and above; on lower versions, use `markPostAsRead` instead.
    /// Calling this will also mark any queued posts as read unless `includeQueuedPosts` is set to `false`.
    func markPostsAsRead(
        ids: Set<Int>,
        read: Bool = true,
        includeQueuedPosts: Bool = true,
        semaphore: UInt? = nil
    ) async throws {
        let version = try await version
        guard version >= .v0_19_0 else { throw ApiClientError.unsupportedLemmyVersion }
        
        let idsToSend: Set<Int>
        let markReadQueueCopy: Set<Int>
        if read, includeQueuedPosts {
            markReadQueueCopy = await markReadQueue.popAll()
            idsToSend = ids.union(markReadQueueCopy)
        } else {
            markReadQueueCopy = []
            idsToSend = ids
        }
        
        guard !idsToSend.isEmpty else { return }
        
        do {
            let request = MarkPostAsReadRequest(endpoint: .v3, postId: nil, read: read, postIds: Array(idsToSend))
            let response = try await perform(request)
            switch response {
            case let .apiSuccessResponse(response):
                if !response.success {
                    throw ApiClientError.unsuccessful
                }
            default:
                break
            }
            if read {
                await markReadQueue.subtract(ids)
            }
        } catch {
            await markReadQueue.union(markReadQueueCopy)
            throw error
        }
        Task { @MainActor in
            for post in idsToSend.compactMap({ caches.post2.retrieveModel(cacheId: $0) }) {
                post.readManager.updateWithReceivedValue(read, semaphore: semaphore)
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
        let request = CreatePostLikeRequest(endpoint: .v3, postId: id, score: score.rawValue)
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func savePost(id: Int, save: Bool, semaphore: UInt? = nil) async throws -> Post2 {
        let request = SavePostRequest(endpoint: .v3, postId: id, save: save)
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func deletePost(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Post2 {
        let request = DeletePostRequest(endpoint: .v3, postId: id, deleted: delete)
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView),
            semaphore: semaphore
        )
    }
    
    /// Added in 0.19.4
    func hidePosts(
        ids: any Collection<Int>,
        hide: Bool,
        semaphore: UInt? = nil
    ) async throws {
        let request = HidePostRequest(endpoint: .v3, postIds: Array(ids), hide: hide, postId: nil)
        let response = try await perform(request)
        switch response {
        case let .apiSuccessResponse(response):
            if !response.success {
                throw ApiClientError.unsuccessful
            }
        default:
            break
        }
        for post in ids.compactMap({ caches.post2.retrieveModel(cacheId: $0) }) {
            post.hiddenManager.updateWithReceivedValue(hide, semaphore: semaphore)
        }
    }
    
    func hidePost(id: Int, hide: Bool, semaphore: UInt? = nil) async throws {
        try await hidePosts(ids: [id], hide: hide, semaphore: semaphore)
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
        let request = CreatePostRequest(
            endpoint: .v3,
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
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView)
        )
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
        let request = EditPostRequest(
            endpoint: .v3,
            postId: id,
            name: title,
            url: linkUrl,
            body: content,
            nsfw: nsfw,
            languageId: languageId,
            altText: altText,
            customThumbnail: thumbnail?.absoluteString,
            tags: nil,
            scheduledPublishTime: nil
        )
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView)
        )
    }

    func replyToPost(id: Int, content: String, languageId: Int? = nil) async throws -> Comment2 {
        let request = CreateCommentRequest(
            endpoint: .v3,
            content: content,
            postId: id,
            parentId: nil,
            languageId: languageId,
            formId: nil
        )
        let response = try await perform(request)
        let comment = try await caches.comment2.getModel(
            api: self,
            from: .init(from: response.commentView)
        )
        comment.getCachedInboxReply()?.setKnownReadState(newValue: true)
        return comment
    }
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> Report {
        let request = CreatePostReportRequest(endpoint: .v3, postId: id, reason: reason, violatesInstanceRules: nil)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.report.getModel(
            api: self,
            from: .init(from: response.postReportView),
            myPersonId: myPersonId
        )
    }
    
    func purgePost(id: Int, reason: String?) async throws {
        let request = PurgePostRequest(endpoint: .v3, postId: id, reason: reason)
        let response = try await perform(request)
        guard response.success else { throw ApiClientError.unsuccessful }
        caches.post1.retrieveModel(cacheId: id)?.purged = true
    }
    
    @discardableResult
    func removePost(
        id: Int,
        remove: Bool,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> Post2 {
        let request = RemovePostRequest(endpoint: .v3, postId: id, removed: remove, reason: reason)
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func pinPost(id: Int, pin: Bool, to target: ApiPostFeatureType, semaphore: UInt? = nil) async throws -> Post2 {
        let request = FeaturePostRequest(endpoint: .v3, postId: id, featured: pin, featureType: target)
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView),
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func lockPost(id: Int, lock: Bool, semaphore: UInt? = nil) async throws -> Post2 {
        let request = LockPostRequest(endpoint: .v3, postId: id, locked: lock)
        let response = try await perform(request)
        return try await caches.post2.getModel(
            api: self,
            from: .init(from: response.postView),
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
        let request = ListPostLikesRequest(endpoint: .v3, postId: id, page: page, limit: limit)
        let response = try await perform(request)
        return try await caches.personVote.getModels(
            api: self,
            from: response.postLikes.map { try .init(from: $0) },
            target: .post(id: id),
            communityId: communityId
        )
    }
}
