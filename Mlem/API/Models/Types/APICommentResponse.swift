//
//  APICommentResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommentResponse.ts
struct APICommentResponse: Codable {
    let comment_view: APICommentView
    let recipient_ids: [Int]
}
