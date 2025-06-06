//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation

public protocol InstanceConnection {
    func updateToken(_ newToken: String)
    
    // MARK: - Post
    
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter?,
        showHidden: Bool
    ) async throws -> (posts: [Post2Snapshot], cursor: String?)
    
    func getPosts(
        feed: ApiListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        filter: GetContentFilter?,
        showHidden: Bool
    ) async throws -> (posts: [Post2Snapshot], cursor: String?)
        
    func getPosts(
        personId: Int,
        communityId: Int?,
        sort: PostSortType,
        page: Int,
        limit: Int,
        savedOnly: Bool
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot])
        
    func getPost(id: Int) async throws -> Post3Snapshot
    func getPost(url: URL) async throws -> Post2Snapshot
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchPosts(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ApiListingType,
        sort: PostSortType
    ) async throws -> [Post2Snapshot]
    
    func searchPosts(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ApiListingType,
        sort: SearchSortType
    ) async throws -> [Post2Snapshot]
    
    func markPostsAsRead(ids: Set<Int>) async throws
    func markPostAsRead(id: Int, read: Bool) async throws
    @discardableResult
    func voteOnPost(id: Int, score: ScoringOperation) async throws -> Post2Snapshot
    @discardableResult
    func savePost(id: Int, save: Bool) async throws -> Post2Snapshot
    @discardableResult
    func deletePost(id: Int, delete: Bool) async throws -> Post2Snapshot
    func hidePost(id: Int, hide: Bool) async throws
    
    func createPost(
        communityId: Int,
        title: String,
        content: String?,
        linkUrl: URL?,
        altText: String?,
        thumbnail: URL?,
        nsfw: Bool,
        languageId: Int?
    ) async throws -> Post2Snapshot
    
    @discardableResult
    func editPost(
        id: Int,
        title: String,
        content: String?,
        linkUrl: URL?,
        altText: String?,
        thumbnail: URL?,
        nsfw: Bool,
        languageId: Int?
    ) async throws -> Post2Snapshot
    
    func replyToPost(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2Snapshot
    
    @discardableResult
    func reportPost(id: Int, reason: String) async throws -> ReportSnapshot
    func purgePost(id: Int, reason: String?) async throws
    
    @discardableResult
    func removePost(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Post2Snapshot
    
    @discardableResult
    func pinPost(
        id: Int,
        pin: Bool,
        to target: ApiPostFeatureType
    ) async throws -> Post2Snapshot
    
    @discardableResult
    func lockPost(id: Int, lock: Bool) async throws -> Post2Snapshot
    
    @discardableResult
    func getPostVotes(
        id: Int,
        communityId: Int,
        page: Int,
        limit: Int
    ) async throws -> [PersonVoteSnapshot]
    
    // MARK: - Comment
    
    func getComment(id: Int) async throws -> Comment2Snapshot
    func getComment(url: URL) async throws -> Comment2Snapshot
    
    func getComments(
        postId: Int,
        sort: ApiCommentSortType,
        page: Int,
        maxDepth: Int?,
        limit: Int,
        filter: GetContentFilter?
    ) async throws -> [Comment2Snapshot]
    
    func getComments(
        parentId: Int,
        sort: CommentSortType,
        page: Int,
        maxDepth: Int?,
        limit: Int,
        filter: GetContentFilter?
    ) async throws -> [Comment2Snapshot]
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ApiListingType,
        sort: CommentSortType
    ) async throws -> [Comment2Snapshot]
    
    func searchComments(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ApiListingType,
        sort: SearchSortType
    ) async throws -> [Comment2Snapshot]
    
    @discardableResult
    func voteOnComment(id: Int, score: ScoringOperation) async throws -> Comment2Snapshot
    @discardableResult
    func saveComment(id: Int, save: Bool) async throws -> Comment2Snapshot
    @discardableResult
    func deleteComment(id: Int, delete: Bool) async throws -> Comment2Snapshot
    
    @discardableResult
    func editComment(
        id: Int,
        content: String,
        languageId: Int?
    ) async throws -> Comment2Snapshot
    
    func replyToComment(postId: Int, parentId: Int?, content: String, languageId: Int?) async throws -> Comment2Snapshot
    
    @discardableResult
    func reportComment(id: Int, reason: String) async throws -> ReportSnapshot
    func purgeComment(id: Int, reason: String?) async throws
    
    @discardableResult
    func removeComment(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Comment2Snapshot
    
    @discardableResult
    func getCommentVotes(
        id: Int,
        communityId: Int,
        page: Int,
        limit: Int
    ) async throws -> [PersonVoteSnapshot]
    
    // MARK: - Person
    
    func getPerson(id: Int) async throws -> Person3Snapshot
    func getPerson(url: URL) async throws -> Person2Snapshot
    func getPerson(username: String) async throws -> Person3Snapshot
    func getPerson(url: URL) async throws -> Person3Snapshot
    
    func searchPeople(
        query: String,
        page: Int,
        limit: Int,
        filter: ApiListingType,
        sort: SearchSortType
    ) async throws -> [Person2Snapshot]
    
    @discardableResult
    func blockPerson(id: Int, block: Bool) async throws -> Person2Snapshot
    
    @discardableResult
    func banPersonFromCommunity(
        personId: Int,
        communityId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date?
    ) async throws -> Person2Snapshot
    
    @discardableResult
    func banPersonFromInstance(
        personId: Int,
        ban: Bool,
        removeContent: Bool,
        reason: String?,
        expires: Date?
    ) async throws -> Person2Snapshot
    
    func purgePerson(id: Int, reason: String?) async throws
    
    func getContent(
        authorId id: Int,
        sort: ApiSortType,
        page: Int,
        limit: Int,
        savedOnly: Bool?,
        communityId: Int?
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot], comments: [Comment2Snapshot])
    
    func getMyPerson() async throws -> (person: Person4Snapshot?, instance: Instance3Snapshot, blocks: BlockListSnapshot?)
    func deleteAccount(password: String, deleteContent: Bool) async throws
    
    func editAccountSettings(
        showNsfw: Bool?,
        showScores: Bool?,
        theme: String?,
        defaultListingType: ApiListingType?,
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
        postListingMode: ApiPostListingMode?,
        enableKeyboardNavigation: Bool?,
        enableAnimatedImages: Bool?,
        collapseBotComments: Bool?,
        showUpvotes: Bool?,
        showDownvotes: Bool?,
        showUpvotePercentage: Bool?
    ) async throws
}
