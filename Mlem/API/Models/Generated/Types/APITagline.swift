//
//  APITagline.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/Tagline.ts
struct APITagline: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let localSiteId: Int
    let content: String
    let published: Date
    let updated: Date?
}
