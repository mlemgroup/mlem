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
    // swiftlint:disable:next identifier_name
    let id: Int
    let creatorId: Int
    let commentId: Int
    let originalCommentText: String
    let reason: String
    let resolved: Bool
    let resolverId: Int?
    let published: Date
    let updated: Date?
}
