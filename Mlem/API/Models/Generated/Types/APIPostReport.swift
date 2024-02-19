//
//  APIPostReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/PostReport.ts
struct APIPostReport: Codable {
    let id: Int
    let creatorId: Int
    let postId: Int
    let originalPostName: String
    let originalPostUrl: String?
    let originalPostBody: String?
    let reason: String
    let resolved: Bool
    let resolverId: Int?
    let published: Date
    let updated: Date?
}
