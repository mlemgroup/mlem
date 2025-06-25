//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Person4Snapshot {
    init(from userInfo: PieFedMyUserInfo) throws(ApiClientError) {
        self.person = try .init(from: userInfo)
        
        let user = userInfo.localUserView.localUser
        
        self.email = nil
        self.showNsfw = user.showNsfw
        self.theme = ""
        self.defaultListingType = .init(from: user.defaultListingType) ?? .all
        self.interfaceLanguage = "en"
        self.showAvatars = true
        self.sendNotificationsToEmail = false
        self.showScores = user.showScores
        self.showBotAccounts = user.showBotAccounts
        self.showReadPosts = user.showReadPosts
        self.discussionLanguageIds = Set(userInfo.discussionLanguages.compactMap(\.id))
        self.emailVerified = true
        self.acceptedApplication = true
        self.openLinksInNewTab = nil
        self.blurNsfw = nil
        self.autoExpandImages = nil
        self.infiniteScrollEnabled = nil
        self.totp2faEnabled = false
        self.enableKeyboardNavigation = true
        self.enableAnimatedImages = nil
        self.collapseBotComments = false
    }
}
