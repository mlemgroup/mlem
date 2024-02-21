//
//  ApiCommentResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommentResponse.ts
struct ApiCommentResponse: Codable {
    let commentView: ApiCommentView
    let recipientIds: [Int]
    let formId: String?
}
