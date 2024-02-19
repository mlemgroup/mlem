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
    let id: Int
    let local_site_id: Int
    let content: String
    let published: Date
    let updated: Date?
}
