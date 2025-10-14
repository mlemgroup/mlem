//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Person4Snapshot {
    init(from userInfo: PieFedMyUserInfo) throws(ApiClientError) {
        let user = userInfo.localUserView.localUser
        try self.init(
            person: .init(from: userInfo),
            email: nil,
            showNsfw: user.showNsfw,
            theme: "",
            defaultListingType: .init(from: user.defaultListingType) ?? .all,
            interfaceLanguage: "en",
            showAvatars: true,
            sendNotificationsToEmail: false,
            showScores: user.showScores,
            showBotAccounts: user.showBotAccounts,
            showReadPosts: user.showReadPosts,
            discussionLanguageIds: Set(userInfo.discussionLanguages.compactMap(\.id)),
            emailVerified: true,
            acceptedApplication: true,
            openLinksInNewTab: nil,
            blurNsfw: nil,
            autoExpandImages: nil,
            infiniteScrollEnabled: nil,
            postListingMode: nil,
            totp2faEnabled: false,
            enableKeyboardNavigation: true,
            enableAnimatedImages: nil,
            collapseBotComments: false
        )
    }
}
