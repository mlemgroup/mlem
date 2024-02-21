//
//  ApiLocalSiteRateLimit.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// LocalSiteRateLimit.ts
struct ApiLocalSiteRateLimit: Codable {
    let localSiteId: Int
    let message: Int
    let messagePerSecond: Int
    let post: Int
    let postPerSecond: Int
    let register: Int
    let registerPerSecond: Int
    let image: Int
    let imagePerSecond: Int
    let comment: Int
    let commentPerSecond: Int
    let search: Int
    let searchPerSecond: Int
    let published: Date
    let updated: Date?
    let importUserSettings: Int?
    let importUserSettingsPerSecond: Int?
    let id: Int?
}
