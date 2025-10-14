//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-04.
//

import Foundation

public struct Person4Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Person2.
    public let person: Person3Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Person3!
    public var email: String?
    public var showNsfw: Bool
    public var theme: String
    public var defaultListingType: ListingType
    public var interfaceLanguage: String
    public var showAvatars: Bool
    public var sendNotificationsToEmail: Bool
    public var showScores: Bool
    public var showBotAccounts: Bool
    public var showReadPosts: Bool
    public var discussionLanguageIds: Set<Int>
    public var emailVerified: Bool
    public var acceptedApplication: Bool
    public var openLinksInNewTab: Bool?
    public var blurNsfw: Bool?
    public var autoExpandImages: Bool?
    public var infiniteScrollEnabled: Bool?
    public var postListingMode: PostFeedViewMode?
    public var totp2faEnabled: Bool?
    public var enableKeyboardNavigation: Bool?
    public var enableAnimatedImages: Bool?
    public var collapseBotComments: Bool?

    public var cacheId: Int { person.cacheId }
    
    public init(
        person: Person3Snapshot,
        email: String? = nil,
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
        openLinksInNewTab: Bool? = nil,
        blurNsfw: Bool? = nil,
        autoExpandImages: Bool? = nil,
        infiniteScrollEnabled: Bool? = nil,
        postListingMode: PostFeedViewMode? = nil,
        totp2faEnabled: Bool? = nil,
        enableKeyboardNavigation: Bool? = nil,
        enableAnimatedImages: Bool? = nil,
        collapseBotComments: Bool? = nil
    ) {
        self.person = person
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
}
