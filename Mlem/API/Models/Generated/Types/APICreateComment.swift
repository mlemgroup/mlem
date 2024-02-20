//
//  APICreateComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CreateComment.ts
struct APICreateComment: Codable {
    let content: String
    let postId: Int
    let parentId: Int?
    let languageId: Int?
    let formId: String?
}
