//
//  APISaveUserSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/SaveUserSettings.ts
struct APISaveUserSettings: Codable {
    let showNsfw: Bool?
    let blurNsfw: Bool?
    let autoExpand: Bool?
    let showScores: Bool?
    let theme: String?
    let defaultSortType: APISortType?
    let defaultListingType: APIListingType?
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
    let postListingMode: APIPostListingMode?
    let enableKeyboardNavigation: Bool?
    let enableAnimatedImages: Bool?
    let collapseBotComments: Bool?
}
