//
//  APICommentResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommentResponse.ts
struct APICommentResponse: Codable {
    let commentView: APICommentView
    let recipientIds: [Int]
    let formId: String?
}
