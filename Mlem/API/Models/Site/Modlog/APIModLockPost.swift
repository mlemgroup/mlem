//
//  APIModLockPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModLockPost.ts
struct APIModLockPost: Decodable {
    let id: Int
    let modPersonId: Int
    let postId: Int
    let locked: Bool
    let when_: String
}
