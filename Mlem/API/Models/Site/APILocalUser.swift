//
//  APILocalUser.swift
//  Mlem
//
//  Created by Sjmarf on 22/11/2023.
//

import Foundation

// lemmy_api_common::site::LocalUser
struct APILocalUser: Decodable {
    var acceptedApplication: Bool
    
    var defaultListingType: APIListingType?
    var defaultSortType: PostSortType?
    
    var email: String?
    var emailVerified: Bool?
    var id: Int
    var interfaceLanguage: String
    
    // can be nil on old instances (introduced somewhere after 0.17.3)
    var openLinksInNewTab: Bool?
    
    // New sometime between 0.17.3 and 0.18.5
    var infiniteScrollEnabled: Bool?
    
    var personId: Int
    var sendNotificationsToEmail: Bool
    var showAvatars: Bool
    var showBotAccounts: Bool
    var showNewPostNotifs: Bool?
    var showNsfw: Bool
    var showReadPosts: Bool
    var showScores: Bool
    var theme: String
    var totp2faUrl: String?
    var validatorTime: String?
}
