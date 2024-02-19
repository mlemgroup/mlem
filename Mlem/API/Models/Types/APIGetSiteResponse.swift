//
//  APIGetSiteResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetSiteResponse.ts
struct APIGetSiteResponse: Codable {
    let site_view: APISiteView
    let admins: [APIPersonView]
    let version: String
    let my_user: APIMyUserInfo?
    let all_languages: [APILanguage]
    let discussion_languages: [Int]
    let taglines: [APITagline]
    let custom_emojis: [APICustomEmojiView]
}
