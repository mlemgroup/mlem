//
//  APIModRemoveComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemoveComment.ts
struct APIModRemoveComment: Decodable {
    let id: Int
    let modPersonId: Int
    let commentId: Int
    let reason: String?
    let removed: Bool
    let when_: String
}
