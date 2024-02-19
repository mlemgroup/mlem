//
//  APICreateComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CreateComment.ts
struct APICreateComment: Codable {
    let content: String
    let post_id: Int
    let parent_id: Int?
    let language_id: Int?
}
