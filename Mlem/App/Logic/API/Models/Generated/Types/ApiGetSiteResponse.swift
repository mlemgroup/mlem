//
//  ApiGetSiteResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetSiteResponse.ts
struct ApiGetSiteResponse: Codable {
    let siteView: ApiSiteView
    let admins: [ApiPersonView]
    let version: String
    let myUser: ApiMyUserInfo?
    let allLanguages: [ApiLanguage]
    let discussionLanguages: [Int]
    let taglines: [ApiTagline]
    let customEmojis: [ApiCustomEmojiView]
}
