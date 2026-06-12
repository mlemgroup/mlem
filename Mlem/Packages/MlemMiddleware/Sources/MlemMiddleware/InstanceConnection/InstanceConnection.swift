//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-05.
//

import Foundation

internal protocol InstanceConnection {
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

    // This should do the minimum work required to retrieve the version,
    // and should be compatible with as many versions as possible (including
    // those outside Mlem's supported version range).
    func getVersionFallback() async throws -> SiteVersion

    // MARK: - Post
    
    func getPosts(
        communityId: Int,
        pageInfo: PageInfo,
        sort: PostSortType,
        filter: GetContentFilter?,
        showHidden: Bool
    ) async throws -> PagedResponse<Post2Snapshot>
    
    func getPosts(
        feed: ListingType,
        pageInfo: PageInfo,
        sort: PostSortType,
        limit: Int,
        filter: GetContentFilter?,
        showHidden: Bool
    ) async throws -> PagedResponse<Post2Snapshot>
        
    func getPosts(
        personId: Int,
        communityId: Int?,
        pageInfo: PageInfo,
        sort: PostSortType,
        limit: Int,
        savedOnly: Bool
    ) async throws -> PagedResponse<Post2Snapshot>
        
    func getPostHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Post2Snapshot>

    func getPost(id: Int) async throws -> Post3Snapshot
    func getPost(url: URL) async throws -> Post2Snapshot
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchPosts(
        query: String,
        pageInfo: PageInfo,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        sort: PostSortType
    ) async throws -> PagedResponse<Post2Snapshot>
    
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
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVoteSnapshot>

    @discardableResult
    func voteInPoll(postId: Int, choiceIds: Set<Int>) async throws -> Post2Snapshot 
    
    // MARK: - Comment
    
    func getComment(id: Int) async throws -> Comment2Snapshot
    func getComment(url: URL) async throws -> Comment2Snapshot

    func getComments(
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int?,
        filter: GetContentFilter?
    ) async throws -> PagedResponse<Comment2Snapshot>
    
    func getComments(
        postId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int?,
        limit: Int,
        filter: GetContentFilter?
    ) async throws -> PagedResponse<Comment2Snapshot>
    
    func getComments(
        parentId: Int,
        pageInfo: PageInfo,
        sort: CommentSortType,
        maxDepth: Int?,
        filter: GetContentFilter?
    ) async throws -> PagedResponse<Comment2Snapshot>

    func getCommentHistory(
        type: GetContentFilter,
        pageInfo: PageInfo
    ) async throws -> PagedResponse<Comment2Snapshot>
    
    // This method should be removed in favor of the below method once we drop support for versions before Lemmy 1.0
    func searchComments(
        query: String,
        pageInfo: PageInfo,
        communityId: Int?,
        creatorId: Int?,
        filter: ListingType,
        sort: CommentSortType
    ) async throws -> PagedResponse<Comment2Snapshot>
    
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
        pageInfo: PageInfo
    ) async throws -> PagedResponse<PersonVoteSnapshot>
    
    // MARK: - Person
    
    func getPerson(id: Int) async throws -> Person3Snapshot
    func getPerson(url: URL) async throws -> Person2Snapshot
    func getPerson(username: String) async throws -> Person3Snapshot
    
    func searchPeople(
        query: String,
        pageInfo: PageInfo,
        filter: ListingType,
        sort: PersonSortType
    ) async throws -> PagedResponse<Comment2Snapshot>
    
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
        pageInfo: PageInfo,
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

    func editCommunityDescription(id: Int, newValue: String?) async throws -> Community2Snapshot 
    
    func searchCommunities(
        query: String,
        pageInfo: PageInfo,
        filter: ListingType,
        sort: CommunitySortType
    ) async throws -> PagedResponse<Community2Snapshot>
    
    @discardableResult
    func getSubscriptionList(pageInfo: PageInfo) async throws -> PagedResponse<Community2Snapshot>

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
        pageInfo: PageInfo,
        communityId: Int?,
        moderatorId: Int?,
        subjectPersonId: Int?,
        postId: Int?,
        commentId: Int?,
        type: ModlogEntryType?
    ) async throws -> PagedResponse<ModlogEntrySnapshot>
    
    func getPostLink(url: URL) async throws -> PostLink

    // MARK: - Inbox
    
    func getMessages(
        creatorId: Int?,
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<Message2Snapshot>
    
    func getReplyNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot>

    func getMentionNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot>

    func getMessageNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot>

    func markNotificationAsRead(
        type: InboxNotificationContentType,
        id: Int,
        contentId: Int,
        read: Bool
    ) async throws
        
    func markAllAsRead() async throws
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
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<RegistrationApplicationSnapshot>
    
    @discardableResult
    func approveRegistrationApplication(id: Int) async throws -> RegistrationApplicationSnapshot
    @discardableResult
    func denyRegistrationApplication(id: Int, reason: String?) async throws -> RegistrationApplicationSnapshot
    
    // MARK: - Report
    
    func getReportCount(communityId: Int?) async throws -> ReportUnreadCountSnapshot
    
    func getPostReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool,
        communityId: Int?,
        postId: Int?
    ) async throws -> PagedResponse<ReportSnapshot>
    
    func getCommentReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool,
        communityId: Int?,
        commentId: Int?
    ) async throws -> PagedResponse<ReportSnapshot>
    
    func getMessageReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool
    ) async throws -> PagedResponse<ReportSnapshot>
    
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
