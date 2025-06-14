//
//  Person4.swift
//
//
//  Created by Sjmarf on 20/05/2024.
//

import Foundation
import Observation

@Observable
public final class Person4: Person4Providing {
    public static let tierNumber: Int = 4
    public var api: ApiClient
    public var person4: Person4 { self }

    public let person3: Person3
    
    public internal(set) var voteDisplayMode: ApiLocalUserVoteDisplayMode?
    public internal(set) var email: String?
    public internal(set) var showNsfw: Bool
    public internal(set) var theme: String
    public internal(set) var defaultListingType: ListingType
    public internal(set) var interfaceLanguage: String
    public internal(set) var showAvatars: Bool
    public internal(set) var sendNotificationsToEmail: Bool
    public internal(set) var showScores: Bool
    public internal(set) var showBotAccounts: Bool
    public internal(set) var showReadPosts: Bool
    public internal(set) var discussionLanguageIds: Set<Int>
    public internal(set) var emailVerified: Bool
    public internal(set) var acceptedApplication: Bool
    public internal(set) var openLinksInNewTab: Bool?
    public internal(set) var blurNsfw: Bool?
    public internal(set) var autoExpandImages: Bool?
    public internal(set) var infiniteScrollEnabled: Bool?
    public internal(set) var postListingMode: PostFeedViewMode?
    public internal(set) var totp2faEnabled: Bool?
    public internal(set) var enableKeyboardNavigation: Bool?
    public internal(set) var enableAnimatedImages: Bool?
    public internal(set) var collapseBotComments: Bool?
    
    init(
        api: ApiClient,
        person3: Person3,
        voteDisplayMode: ApiLocalUserVoteDisplayMode?,
        email: String?,
        showNsfw: Bool,
        theme: String,
        defaultListingType: ListingType,
        interfaceLanguage: String,
        showAvatars: Bool,
        sendNotificationsToEmail: Bool,
        showScores: Bool,
        showBotAccounts: Bool,
        showReadPosts: Bool,
        discussionLanguageIds: Set<Int>,
        emailVerified: Bool,
        acceptedApplication: Bool,
        openLinksInNewTab: Bool?,
        blurNsfw: Bool?,
        autoExpandImages: Bool?,
        infiniteScrollEnabled: Bool?,
        postListingMode: PostFeedViewMode?,
        totp2faEnabled: Bool?,
        enableKeyboardNavigation: Bool?,
        enableAnimatedImages: Bool?,
        collapseBotComments: Bool?
    ) {
        self.api = api
        self.person3 = person3
        self.voteDisplayMode = voteDisplayMode
        self.email = email
        self.showNsfw = showNsfw
        self.theme = theme
        self.defaultListingType = defaultListingType
        self.interfaceLanguage = interfaceLanguage
        self.showAvatars = showAvatars
        self.sendNotificationsToEmail = sendNotificationsToEmail
        self.showScores = showScores
        self.showBotAccounts = showBotAccounts
        self.showReadPosts = showReadPosts
        self.discussionLanguageIds = discussionLanguageIds
        self.emailVerified = emailVerified
        self.acceptedApplication = acceptedApplication
        self.openLinksInNewTab = openLinksInNewTab
        self.blurNsfw = blurNsfw
        self.autoExpandImages = autoExpandImages
        self.infiniteScrollEnabled = infiniteScrollEnabled
        self.postListingMode = postListingMode
        self.totp2faEnabled = totp2faEnabled
        self.enableKeyboardNavigation = enableKeyboardNavigation
        self.enableAnimatedImages = enableAnimatedImages
        self.collapseBotComments = collapseBotComments
    }
    
    public func upgrade() async throws -> any Person { self }
    
    public func updateSettings(
        email: String? = nil,
        matrixId: String? = nil,
        showNsfw: Bool? = nil,
        blurNsfw: Bool? = nil,
        showBotAccounts: Bool? = nil,
        discussionLanguageIds: Set<Int>? = nil,
        sendNotificationsToEmail: Bool? = nil,
        isBot: Bool? = nil
    ) async throws {
        // iirc previous lemmy versions had issues with supplying `nil` for certain setting values.
        // I don't remember which versions this happened on or which parameters couldn't be `nil`.
        // Supplying them all to be safe.
        try await api.editAccountSettings(
            showNsfw: showNsfw ?? self.showNsfw,
            showScores: showScores,
            theme: theme,
            defaultListingType: defaultListingType,
            interfaceLanguage: interfaceLanguage,
            avatar: avatar?.absoluteString ?? "",
            banner: banner?.absoluteString ?? "",
            displayName: displayName,
            email: email ?? self.email,
            bio: description,
            matrixUserId: matrixId ?? self.matrixId,
            showAvatars: showAvatars,
            sendNotificationsToEmail: sendNotificationsToEmail ?? self.sendNotificationsToEmail,
            botAccount: isBot ?? self.isBot,
            showBotAccounts: showBotAccounts ?? self.showBotAccounts,
            showReadPosts: showReadPosts,
            discussionLanguages: discussionLanguageIds?.sorted(),
            openLinksInNewTab: openLinksInNewTab,
            blurNsfw: blurNsfw ?? self.blurNsfw,
            autoExpand: autoExpandImages,
            infiniteScrollEnabled: infiniteScrollEnabled,
            postListingMode: postListingMode,
            enableKeyboardNavigation: enableKeyboardNavigation,
            enableAnimatedImages: enableAnimatedImages,
            collapseBotComments: collapseBotComments,
            showUpvotes: voteDisplayMode?.upvotes,
            showDownvotes: voteDisplayMode?.downvotes,
            showUpvotePercentage: voteDisplayMode?.upvotePercentage
        )
        self.email = email ?? self.email
        person1.matrixId = matrixId ?? self.matrixId
        self.showNsfw = showNsfw ?? self.showNsfw
        self.blurNsfw = blurNsfw ?? self.blurNsfw
        self.showBotAccounts = showBotAccounts ?? self.showBotAccounts
        self.discussionLanguageIds = discussionLanguageIds ?? self.discussionLanguageIds
        self.sendNotificationsToEmail = sendNotificationsToEmail ?? self.sendNotificationsToEmail
        person1.isBot = isBot ?? self.isBot
    }
    
    public func updateProfile(
        displayName: String?,
        description: String?,
        avatar: URL?,
        banner: URL?
    ) async throws {
        try await api.editAccountSettings(
            showNsfw: showNsfw,
            showScores: showScores,
            theme: theme,
            defaultListingType: defaultListingType,
            interfaceLanguage: interfaceLanguage,
            avatar: avatar?.absoluteString ?? "",
            banner: banner?.absoluteString ?? "",
            displayName: displayName ?? "",
            email: email,
            bio: description ?? "",
            matrixUserId: matrixId,
            showAvatars: showAvatars,
            sendNotificationsToEmail: sendNotificationsToEmail,
            botAccount: isBot,
            showBotAccounts: showBotAccounts,
            showReadPosts: showReadPosts,
            discussionLanguages: nil,
            openLinksInNewTab: openLinksInNewTab,
            blurNsfw: blurNsfw,
            autoExpand: autoExpandImages,
            infiniteScrollEnabled: infiniteScrollEnabled,
            postListingMode: postListingMode,
            enableKeyboardNavigation: enableKeyboardNavigation,
            enableAnimatedImages: enableAnimatedImages,
            collapseBotComments: collapseBotComments,
            showUpvotes: voteDisplayMode?.upvotes,
            showDownvotes: voteDisplayMode?.downvotes,
            showUpvotePercentage: voteDisplayMode?.upvotePercentage
        )
        person1.displayName = displayName ?? name
        person1.description = description
        person1.avatar = avatar
        person1.banner = banner
    }
}
