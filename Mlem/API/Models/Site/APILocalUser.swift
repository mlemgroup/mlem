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
    
    let defaultListingType: APIListingType?
    let defaultSortType: PostSortType?
    
    let email: String?
    let emailVerified: Bool?
    let id: Int
    let interfaceLanguage: String
    
    // can be nil on old instances (introduced somewhere after 0.17.3)
    let openLinksInNewTab: Bool?
    
    // New sometime between 0.17.3 and 0.18.5
    let infiniteScrollEnabled: Bool?
    
    let personId: Int
    let sendNotificationsToEmail: Bool
    let showAvatars: Bool
    let showBotAccounts: Bool
    let showNewPostNotifs: Bool?
    let showNsfw: Bool
    let showReadPosts: Bool
    let showScores: Bool
    let theme: String
    let totp2faUrl: String?
    let validatorTime: String?
}
