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
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
    }
    
    func getPost(url: URL) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
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
        legacySort: ApiSortType?,
        sort: ApiSearchSortType?,
        timeRangeSeconds: Int?
    ) async throws -> [Post2Snapshot] {
        throw ApiClientError.featureUnsupported
    }
    
    // Marking many posts as *unread* was possible in 0.19.0, but that capability was removed in 1.0.0
    func markPostsAsRead(ids: Set<Int>) async throws {
        throw ApiClientError.featureUnsupported
    }
    
    func markPostAsRead(id: Int, read: Bool) async throws {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func savePost(id: Int, save: Bool) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func deletePost(id: Int, delete: Bool) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    // Marking many posts as hidden was possible in 0.19.0, but this was removed in 1.0.0
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
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
    }
    
    func replyToPost(
        id: Int,
        content: String,
        languageId: Int? = nil
    ) async throws -> Comment2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> ReportSnapshot {
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func pinPost(
        id: Int,
        pin: Bool,
        to target: PostFeatureType
    ) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func lockPost(id: Int, lock: Bool) async throws -> Post2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func getPostVotes(
        id: Int,
        communityId: Int,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [PersonVoteSnapshot] {
        throw ApiClientError.featureUnsupported
    }
}
