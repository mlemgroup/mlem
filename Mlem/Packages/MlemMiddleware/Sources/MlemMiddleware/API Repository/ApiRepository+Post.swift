//
//  ApiRepository+Post.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

import Foundation

extension ApiRepository {
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post2Snapshot], cursor: String?) {
        try await performingForConnection { connection in
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
    ) async throws -> (posts: [Post2Snapshot], cursor: String?) {
        try await performingForConnection { connection in
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
    }
    
    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        sort: PostSortType = .new,
        page: Int,
        limit: Int,
        savedOnly: Bool = false
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot]) {
        try await performingForConnection { connection in
            try await connection.getPosts(
                personId: personId,
                communityId: communityId,
                sort: sort,
                page: page,
                limit: limit,
                savedOnly: savedOnly
            )
        }
    }
        
    func getPostHistory(
        type: GetContentFilter,
        page: Int?,
        cursor: String?,
        limit: Int
    ) async throws -> (posts: [Post2Snapshot], cursor: String?) {
        try await performingForConnection { connection in
            try await connection.getPostHistory(
                type: type,
                page: page,
                cursor: cursor,
                limit: limit
            )
        }
    }
    
    func getPost(id: Int) async throws -> Post3Snapshot {
        try await performingForConnection { connection in
            try await connection.getPost(id: id)
        }
    }
    
    func getPost(url: URL) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.getPost(url: url)
        }
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
        try await performingForConnection { connection in
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
        try await performingForConnection { connection in
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
    }
    
    func markPostAsRead(id: Int, read: Bool = true) async throws {
        try await performingForConnection { connection in
            try await connection.markPostAsRead(id: id, read: read)
        }
    }
    
    func markPostsAsRead(ids: Set<Int>, read: Bool = true) async throws {
        try await performingForConnection { connection in
            try await connection.markPostsAsRead(ids: ids, read: read)
        }
    }
    
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.voteOnPost(id: id, score: score)
        }
    }

    func savePost(id: Int, save: Bool) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.savePost(id: id, save: save)
        }
    }

    func setPostNotificationsEnabled(id: Int, enabled: Bool) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.setPostNotificationsEnabled(id: id, enabled: enabled)
        }
    }

    func deletePost(id: Int, delete: Bool) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.deletePost(id: id, delete: delete)
        }
    }
    
    /// Added in 0.19.4
    func hidePost(
        id: Int,
        hide: Bool
    ) async throws {
        try await performingForConnection { connection in
            try await connection.hidePost(id: id, hide: hide)
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
        try await performingForConnection { connection in
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
    }
    
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
        try await performingForConnection { connection in
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
    }

    func replyToPost(id: Int, content: String, languageId: Int? = nil) async throws -> Comment2Snapshot {
        try await performingForConnection { connection in
            try await connection.replyToPost(id: id, content: content, languageId: languageId)
        }
    }
    
    func reportPost(id: Int, reason: String) async throws -> ReportSnapshot {
        try await performingForConnection { connection in
            try await connection.reportPost(id: id, reason: reason)
        }
    }
    
    func purgePost(id: Int, reason: String?) async throws {
        try await performingForConnection { connection in
            try await connection.purgePost(id: id, reason: reason)
        }
    }
    
    func removePost(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.removePost(id: id, remove: remove, reason: reason)
        }
    }
    
    func pinPost(
        id: Int,
        pin: Bool,
        to target: PostFeatureType
    ) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.pinPost(id: id, pin: pin, to: target)
        }
    }
    
    func lockPost(
        id: Int,
        lock: Bool
    ) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.lockPost(id: id, lock: lock)
        }
    }
    
    func setPostNsfw(id: Int, nsfw: Bool) async throws -> Post1Snapshot {
        try await performingForConnection { connection in
            try await connection.setPostNsfw(id: id, nsfw: nsfw)
        }
    }
    
    func getPostVotes(
        id: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        try await performingForConnection { connection in
            try await connection.getPostVotes(
                id: id,
                page: page,
                limit: limit
            )
        }
    }

    @discardableResult
    func voteInPoll(postId: Int, choiceIds: Set<Int>) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.voteInPoll(postId: postId, choiceIds: choiceIds)
        }
    }
}
