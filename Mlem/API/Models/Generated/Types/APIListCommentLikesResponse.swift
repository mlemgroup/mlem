//
//  APIListCommentLikesResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ListCommentLikesResponse.ts
struct APIListCommentLikesResponse: Codable {
    let comment_likes: [APIVoteView]
}
