//
//  APICommentResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CommentResponse.ts
struct APICommentResponse: Codable {
    let comment_view: APICommentView
    let recipient_ids: [Int]
}
