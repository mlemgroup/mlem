//
//  APIModLockPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModLockPost.ts
struct APIModLockPost: Codable {
    let id: Int
    let mod_person_id: Int
    let post_id: Int
    let locked: Bool
    let when_: String
}
