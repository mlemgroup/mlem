//
//  APILocalUser.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import Foundation

// lemmy_api_common::site::LocalUser
struct APILocalUser: Decodable {
    let acceptedApplication: Bool
    // let defaultListingType
    // let defaultSortType
    let email: String?
    let emailVerified: Bool?
    let id: Int
    let interfaceLanguage: String
    let openLinksInNewTab: Bool
    let personId: Int
    let sendNotificationsToEmail: Bool
    let showAvatars: Bool
    let showBotAccounts: Bool
    let showNewPostNotifs: Bool
    let showNsfw: Bool
    let showReadPosts: Bool
    let showScores: Bool
    let theme: String
    let totp2faUrl: String
    let validatorTime: String
}
