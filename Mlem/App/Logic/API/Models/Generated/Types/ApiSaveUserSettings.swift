//
//  ApiSaveUserSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// SaveUserSettings.ts
struct ApiSaveUserSettings: Codable {
    let showNsfw: Bool?
    let blurNsfw: Bool?
    let autoExpand: Bool?
    let showScores: Bool?
    let theme: String?
    let defaultSortType: ApiSortType?
    let defaultListingType: ApiListingType?
    let interfaceLanguage: String?
    let avatar: URL?
    let banner: URL?
    let displayName: String?
    let email: String?
    let bio: String?
    let matrixUserId: String?
    let showAvatars: Bool?
    let sendNotificationsToEmail: Bool?
    let botAccount: Bool?
    let showBotAccounts: Bool?
    let showReadPosts: Bool?
    let discussionLanguages: [Int]?
    let openLinksInNewTab: Bool?
    let infiniteScrollEnabled: Bool?
    let postListingMode: ApiPostListingMode?
    let enableKeyboardNavigation: Bool?
    let enableAnimatedImages: Bool?
    let collapseBotComments: Bool?
    let showNewPostNotifs: Bool?
    let generateTotp2fa: Bool?
}
