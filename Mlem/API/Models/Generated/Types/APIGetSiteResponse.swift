//
//  APIGetSiteResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetSiteResponse.ts
struct APIGetSiteResponse: Codable {
    let siteView: APISiteView
    let admins: [APIPersonView]
    let version: String
    let myUser: APIMyUserInfo?
    let allLanguages: [APILanguage]
    let discussionLanguages: [Int]
    let taglines: [APITagline]
    let customEmojis: [APICustomEmojiView]
}
