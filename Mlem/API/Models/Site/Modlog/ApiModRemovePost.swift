//
//  APIModRemovePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemovePost.ts
struct APIModRemovePost: Decodable {
    let id: Int
    let mod_person_id: Int
    let post_id: Int
    let reason: String?
    let removed: Bool
    let when_: String
}
