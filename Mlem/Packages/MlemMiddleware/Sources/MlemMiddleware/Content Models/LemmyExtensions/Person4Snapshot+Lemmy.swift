//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Person4Snapshot {
    init(from userInfo: LemmyMyUserInfo) throws(ApiClientError) {
        self.person = try .init(from: userInfo)
        let user = userInfo.localUserView.localUser

        self.email = user.email
        self.showNsfw = user.showNsfw
        self.theme = user.theme
        self.defaultListingType = try .init(from: user.defaultListingType)
        self.interfaceLanguage = user.interfaceLanguage
        self.showAvatars = user.showAvatars
        self.sendNotificationsToEmail = user.sendNotificationsToEmail
        
        if let showScores = (user.showScore ?? user.showScores) {
            self.showScores = showScores
        } else {
            throw .responseMissingRequiredData("LemmyMyUserInfo showScores")
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
        self.postListingMode = .init(from: user.postListingMode)
        self.totp2faEnabled = user.totp2faEnabled
        self.enableKeyboardNavigation = user.enableKeyboardNavigation
        self.enableAnimatedImages = user.enableAnimatedImages
        self.collapseBotComments = user.collapseBotComments
    }
}
