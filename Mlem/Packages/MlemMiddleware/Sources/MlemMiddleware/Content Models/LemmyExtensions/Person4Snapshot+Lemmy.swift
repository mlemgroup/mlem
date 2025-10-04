//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Person4Snapshot {
    init(from userInfo: LemmyMyUserInfo) throws(ApiClientError) {
        let user = userInfo.localUserView.localUser

        guard let showScores = (user.showScore ?? user.showScores) else {
            throw .responseMissingRequiredData("LemmyMyUserInfo showScores")
        }

        try self.init(
            person: .init(from: userInfo),
            email: user.email,
            showNsfw: user.showNsfw,
            theme: user.theme,
            defaultListingType: .init(from: user.defaultListingType),
            interfaceLanguage: user.interfaceLanguage,
            showAvatars: user.showAvatars,
            sendNotificationsToEmail: user.sendNotificationsToEmail,
            showScores: showScores,
            showBotAccounts: user.showBotAccounts,
            showReadPosts: user.showReadPosts,
            discussionLanguageIds: .init(userInfo.discussionLanguages.filter { $0 != 0 }),
            emailVerified: user.emailVerified,
            acceptedApplication: user.acceptedApplication,
            openLinksInNewTab: user.openLinksInNewTab,
            blurNsfw: user.blurNsfw,
            autoExpandImages: user.autoExpand,
            infiniteScrollEnabled: user.infiniteScrollEnabled,
            postListingMode: .init(from: user.postListingMode),
            totp2faEnabled: user.totp2faEnabled,
            enableKeyboardNavigation: user.enableKeyboardNavigation,
            enableAnimatedImages: user.enableAnimatedImages,
            collapseBotComments: user.collapseBotComments
        )
    }
}
