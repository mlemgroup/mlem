//
//  APIPostReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/PostReport.ts
struct APIPostReport: Codable {
    let id: Int
    let creator_id: Int
    let post_id: Int
    let original_post_name: String
    let original_post_url: String?
    let original_post_body: String?
    let reason: String
    let resolved: Bool
    let resolver_id: Int?
    let published: Date
    let updated: Date?
}
