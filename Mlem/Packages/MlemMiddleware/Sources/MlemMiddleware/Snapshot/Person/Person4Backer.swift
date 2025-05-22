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
    public var voteDisplayMode: ApiLocalUserVoteDisplayMode?
    public var email: String?
    public var showNsfw: Bool
    public var theme: String
    public var defaultListingType: ApiListingType
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
    public var postListingMode: ApiPostListingMode?
    public var totp2faEnabled: Bool?
    public var enableKeyboardNavigation: Bool?
    public var enableAnimatedImages: Bool?
    public var collapseBotComments: Bool?

    public var cacheId: Int { person.cacheId }
    
    public init(from userInfo: ApiMyUserInfo) throws(ApiClientError) {
        self.person = try .init(from: userInfo)
        let user = userInfo.localUserView.localUser

        self.voteDisplayMode = userInfo.localUserView.localUserVoteDisplayMode
        self.email = user.email
        self.showNsfw = user.showNsfw
        self.theme = user.theme
        self.defaultListingType = user.defaultListingType
        self.interfaceLanguage = user.interfaceLanguage
        self.showAvatars = user.showAvatars
        self.sendNotificationsToEmail = user.sendNotificationsToEmail
        
        if let showScores = (user.showScore ?? user.showScores) {
            self.showScores = showScores
        } else {
            throw .responseMissingRequiredData("ApiMyUserInfo showScores")
        }
        
        self.showBotAccounts = user.showBotAccounts
        self.showReadPosts = user.showReadPosts
        self.discussionLanguageIds = .init(userInfo.discussionLanguages.filter { $0 != 0 })
        self.emailVerified = user.emailVerified
        self.acceptedApplication = user.acceptedApplication
        self.openLinksInNewTab = user.openLinksInNewTab
        self.blurNsfw = user.blurNsfw
        self.autoExpandImages = user.autoExpand
        self.infiniteScrollEnabled = user.infiniteScrollEnabled
        self.postListingMode = user.postListingMode
        self.totp2faEnabled = user.totp2faEnabled
        self.enableKeyboardNavigation = user.enableKeyboardNavigation
        self.enableAnimatedImages = user.enableAnimatedImages
        self.collapseBotComments = user.collapseBotComments
    }
}
