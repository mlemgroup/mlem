//
//  APIModRemovePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModRemovePost.ts
struct APIModRemovePost: Codable {
    let id: Int
    let modPersonId: Int
    let postId: Int
    let reason: String?
    let removed: Bool
    let when_: String
}
