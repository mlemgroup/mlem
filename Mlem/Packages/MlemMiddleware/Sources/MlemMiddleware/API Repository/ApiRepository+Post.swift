//
//  ApiRepository+Post.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

import Foundation

extension ApiRepository {
    func getPosts(
        communityId: Int,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getPosts(
                communityId: communityId,
                pageInfo: pageInfo,
                sort: sort,
                filter: filter,
                showHidden: showHidden
            )
        }
    }

    func getPosts(
        feed: ListingType,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getPosts(
                feed: feed,
                pageInfo: pageInfo,
                sort: sort,
                filter: filter,
                showHidden: showHidden
            )
        }
    }
    
    func getPosts(
        personId: Int,
        communityId: Int? = nil,
        pageInfo: PageInfo,
        sort: PostSortType = .new,
        savedOnly: Bool = false
    ) async throws -> PagedResponse<Post2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getPosts(
                personId: personId,
                communityId: communityId,
                pageInfo: pageInfo,
                sort: sort,
                savedOnly: savedOnly
            )
        }
    }
        
    func getPostHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Post2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getPostHistory(
                type: type,
                pageInfo: pageInfo
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
        pageInfo: PageInfo,
        communityId: Int? = nil,
        creatorId: Int? = nil,
        filter: ListingType = .all,
        sort: PostSortType
    ) async throws -> PagedResponse<Post2Snapshot> {
        try await performingForConnection { connection in
            try await connection.searchPosts(
                query: query,
                pageInfo: pageInfo,
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
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVoteSnapshot> {
        try await performingForConnection { connection in
            try await connection.getPostVotes(id: id, pageInfo: pageInfo)
        }
    }

    @discardableResult
    func voteInPoll(postId: Int, choiceIds: Set<Int>) async throws -> Post2Snapshot {
        try await performingForConnection { connection in
            try await connection.voteInPoll(postId: postId, choiceIds: choiceIds)
        }
    }
}
