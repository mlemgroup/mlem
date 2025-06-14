//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-06.
//

import Foundation

public extension PieFedConnection {
    func getPerson(id: Int) async throws -> Person3Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getPerson(url: URL) async throws -> Person2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getPerson(username: String) async throws -> Person3Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getPerson(url: URL) async throws -> Person3Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    /// `filter` can be set to `.local` from 0.19.4 onwards.
    func searchPeople(
        query: String,
        page: Int = 1,
        limit: Int = 20,
        filter: ListingType = .all,
        sort: SearchSortType = .top(.allTime)
    ) async throws -> [Person2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func blockPerson(id: Int, block: Bool) async throws -> Person2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func banPersonFromCommunity(
        personId: Int,
        communityId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func banPersonFromInstance(
        personId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date? = nil
    ) async throws -> Person2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func purgePerson(id: Int, reason: String?) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getContent(
        authorId id: Int,
        sort: PostSortType,
        page: Int,
        limit: Int,
        savedOnly: Bool? = nil,
        communityId: Int? = nil
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot], comments: [Comment2Snapshot]) {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    // Returns a raw API type. For use inside LemmyConnection only
    internal func rawGetMyPerson() async throws -> ApiGetSiteResponse {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    // Calls rawGetMyPerson, but if there's already a task running in the `contextDataManager` uses that instead.
    internal func rawGetMyPersonWithContext() async throws -> ApiGetSiteResponse {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getMyPerson() async throws -> (person: Person4Snapshot?, instance: Instance3Snapshot, blocks: BlockListSnapshot?) {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func deleteAccount(password: String, deleteContent: Bool) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func editAccountSettings(
        showNsfw: Bool?,
        showScores: Bool?,
        theme: String?,
        defaultListingType: ListingType?,
        interfaceLanguage: String?,
        avatar: String?,
        banner: String?,
        displayName: String?,
        email: String?,
        bio: String?,
        matrixUserId: String?,
        showAvatars: Bool?,
        sendNotificationsToEmail: Bool?,
        botAccount: Bool?,
        showBotAccounts: Bool?,
        showReadPosts: Bool?,
        discussionLanguages: [Int]?,
        openLinksInNewTab: Bool?,
        blurNsfw: Bool?,
        autoExpand: Bool?,
        infiniteScrollEnabled: Bool?,
        postListingMode: PostFeedViewMode?,
        enableKeyboardNavigation: Bool?,
        enableAnimatedImages: Bool?,
        collapseBotComments: Bool?,
        showUpvotes: Bool?,
        showDownvotes: Bool?,
        showUpvotePercentage: Bool?
    ) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
}
