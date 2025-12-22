//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation

public protocol InstanceConnection {
    static var softwareType: SiteSoftwareType { get }
    
    init(baseUrl: URL, token: String?)
        
    func updateToken(_ newToken: String)
    
    var contextIsFetched: Bool { get }
    func supports(_ feature: Feature) async throws -> Bool
    func supports(_ feature: Feature, defaultValue: Bool) -> Bool

    var fetchedVersion: SiteVersion? { get }
    var version: SiteVersion { get async throws }
    var myPersonId: Int? { get async throws }
    func ensureContextPresence() async throws

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
        feed: ListingType,
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
        
    func getPostHistory(
        type: GetContentFilter,
        page: Int?,
        cursor: String?,
        limit: Int
    ) async throws -> (posts: [Post2Snapshot], cursor: String?)

    func getPost(id: Int) async throws -> Post3Snapshot
    func getPost(url: URL) async throws -> Post2Snapshot
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchPosts(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        sort: PostSortType
    ) async throws -> [Post2Snapshot]
    
    func searchPosts(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        sort: SearchSortType
    ) async throws -> [Post2Snapshot]
    
    func markPostsAsRead(ids: Set<Int>, read: Bool) async throws
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
        to target: PostFeatureType
    ) async throws -> Post2Snapshot
    
    @discardableResult
    func lockPost(id: Int, lock: Bool) async throws -> Post2Snapshot
    
    @discardableResult
    func setPostNsfw(id: Int, nsfw: Bool) async throws -> Post1Snapshot
    
    @discardableResult
    func getPostVotes(
        id: Int,
        page: Int,
        limit: Int
    ) async throws -> [PersonVoteSnapshot]
    
    // MARK: - Comment
    
    func getComment(id: Int) async throws -> Comment2Snapshot
    func getComment(url: URL) async throws -> Comment2Snapshot

    func getComments(
        sort: CommentSortType,
        page: Int,
        maxDepth: Int?,
        limit: Int,
        filter: GetContentFilter?
    ) async throws -> [Comment2Snapshot]
    
    func getComments(
        postId: Int,
        sort: CommentSortType,
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

    func getCommentHistory(
        type: GetContentFilter,
        page: Int?,
        cursor: String?,
        limit: Int
    ) async throws -> (comments: [Comment2Snapshot], cursor: String?)
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        sort: CommentSortType
    ) async throws -> [Comment2Snapshot]
    
    func searchComments(
        query: String,
        page: Int,
        limit: Int,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
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
        filter: ListingType,
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
    ) async throws -> Person1Snapshot
    
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
        sort: PostSortType,
        page: Int,
        limit: Int,
        savedOnly: Bool?,
        communityId: Int?
    ) async throws -> (person: Person3Snapshot, posts: [Post2Snapshot], comments: [Comment2Snapshot])
    
    func getMyPerson() async throws -> (person: Person4Snapshot?, instance: Instance3Snapshot, blocks: BlockListSnapshot?)
    func deleteAccount(password: String, deleteContent: Bool) async throws

    func editNote(id: Int, content: String?) async throws

    func editProfile(details: ProfileDetails) async throws
    
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
    ) async throws
    
    // MARK: - Community

    func getCommunity(id: Int) async throws -> Community3Snapshot
    func getCommunity(url: URL) async throws -> Community2Snapshot
    func getCommunity(url: URL) async throws -> Community3Snapshot

    func editCommunityDescription(id: Int, newValue: String?) async throws -> Community2Snapshot 
    
    func searchCommunities(
        query: String,
        page: Int,
        limit: Int,
        filter: ListingType,
        sort: SearchSortType
    ) async throws -> [Community2Snapshot]
    
    @discardableResult
    func getSubscriptionList(page: Int, limit: Int) async throws -> [Community2Snapshot]
    @discardableResult
    func subscribeToCommunity(id: Int, subscribe: Bool) async throws -> Community2Snapshot
    @discardableResult
    func blockCommunity(id: Int, block: Bool) async throws -> Community2Snapshot
    
    @discardableResult
    func removeCommunity(
        id: Int,
        remove: Bool,
        reason: String?
    ) async throws -> Community2Snapshot
    
    func purgeCommunity(id: Int, reason: String?) async throws
    
    @discardableResult
    func addModerator(
        communityId: Int,
        personId: Int,
        added: Bool
    ) async throws -> (moderators: [Person1Snapshot], community: Community1Snapshot)
    
    // MARK: - General

    func getAccountToken(usernameOrEmail: String, password: String, totpToken: String?) async throws -> String
    func getUsernameFromToken(token: String) async throws -> String
    
    func signUp(
        username: String,
        password: String,
        confirmPassword: String,
        showNsfw: Bool,
        email: String?,
        captcha: Captcha?,
        captchaAnswer: String?,
        applicationQuestionResponse: String?
    ) async throws -> SignUpResponse
    
    @discardableResult
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> String
    
    func getCaptcha() async throws -> Captcha
    
    func resolve(url: URL) async throws -> ResolvedContent
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [Instance1Snapshot])
    
    func getModlog(
        page: Int,
        limit: Int,
        communityId: Int?,
        moderatorId: Int?,
        subjectPersonId: Int?,
        postId: Int?,
        commentId: Int?,
        type: ModlogEntryType?
    ) async throws -> [ModlogEntrySnapshot]
    
    func getPostLink(url: URL) async throws -> PostLink

    // MARK: - Inbox
    
    func getReplies(
        sort: CommentSortType,
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [Reply2Snapshot]
    
    func getMentions(
        sort: CommentSortType,
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [Reply2Snapshot]
    
    func getMessages(
        creatorId: Int?,
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [Message2Snapshot]
    
    func getReplyNotifications(
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [InboxNotificationSnapshot]

    func getMentionNotifications(
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [InboxNotificationSnapshot]

    func getMessageNotifications(
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [InboxNotificationSnapshot]

    func markNotificationAsRead(
        type: InboxNotificationContentType,
        id: Int,
        contentId: Int,
        read: Bool
    ) async throws
        
    func markAllAsRead() async throws
    func markReplyAsRead(id: Int, read: Bool) async throws
    func markMentionAsRead(id: Int, read: Bool) async throws
    func markMessageAsRead(id: Int, read: Bool) async throws
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot
    func createMessage(personId: Int, content: String) async throws -> Message2Snapshot
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2Snapshot
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> ReportSnapshot
    @discardableResult
    func deleteMessage(id: Int, delete: Bool) async throws -> Message2Snapshot
    
    // MARK: - Instance
    
    func getMyInstance() async throws -> Instance3Snapshot
    func getFederatedInstances() async throws -> FederationPolicy
    func blockInstance(instanceId: Int, block: Bool) async throws
    @discardableResult
    func addAdmin(personId: Int, added: Bool) async throws -> [Person2Snapshot]
    
    // MARK: - RegistrationApplication
    
    func getRegistrationApplicationCount() async throws -> Int
    
    func getRegistrationApplications(
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [RegistrationApplicationSnapshot]
    
    @discardableResult
    func approveRegistrationApplication(id: Int) async throws -> RegistrationApplicationSnapshot
    @discardableResult
    func denyRegistrationApplication(id: Int, reason: String?) async throws -> RegistrationApplicationSnapshot
    
    // MARK: - Report
    
    func getReportCount(communityId: Int?) async throws -> ReportUnreadCountSnapshot
    
    func getPostReports(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool,
        communityId: Int?,
        postId: Int?
    ) async throws -> [ReportSnapshot]
    
    func getCommentReports(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool,
        communityId: Int?,
        commentId: Int?
    ) async throws -> [ReportSnapshot]
    
    func getMessageReports(
        page: Int,
        limit: Int,
        unresolvedOnly: Bool
    ) async throws -> [ReportSnapshot]
    
    @discardableResult
    func resolvePostReport(id: Int, resolved: Bool) async throws -> ReportSnapshot
    @discardableResult
    func resolveCommentReport(id: Int, resolved: Bool) async throws -> ReportSnapshot
    @discardableResult
    func resolveMessageReport(id: Int, resolved: Bool) async throws -> ReportSnapshot
    
    // MARK: - Image
    
    func uploadImage(
        _ imageData: Data,
        fileExtension: String,
        onProgress progressCallback: @escaping (_ progress: Double) -> Void
    ) async throws -> ImageUpload1Snapshot
    
    func deleteImage(alias: String, deleteToken: String) async throws
}
