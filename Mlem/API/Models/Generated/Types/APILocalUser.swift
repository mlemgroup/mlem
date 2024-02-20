//
//  APILocalUser.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// LocalUser.ts
struct APILocalUser: Codable {
    let id: Int
    let personId: Int
    let email: String?
    let showNsfw: Bool
    let theme: String
    let defaultSortType: APISortType
    let defaultListingType: APIListingType
    let interfaceLanguage: String
    let showAvatars: Bool
    let sendNotificationsToEmail: Bool
    let showScores: Bool
    let showBotAccounts: Bool
    let showReadPosts: Bool
    let emailVerified: Bool
    let acceptedApplication: Bool
    let openLinksInNewTab: Bool
    let blurNsfw: Bool?
    let autoExpand: Bool?
    let infiniteScrollEnabled: Bool?
    let admin: Bool?
    let postListingMode: APIPostListingMode?
    let totp2faEnabled: Bool?
    let enableKeyboardNavigation: Bool?
    let enableAnimatedImages: Bool?
    let collapseBotComments: Bool?
    let validatorTime: String?
    let showNewPostNotifs: Bool?
    let totp2faUrl: String?
}
