//
//  APICommentReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CommentReport.ts
struct APICommentReport: Codable {
    let id: Int
    let creator_id: Int
    let comment_id: Int
    let original_comment_text: String
    let reason: String
    let resolved: Bool
    let resolver_id: Int?
    let published: Date
    let updated: Date?
}
