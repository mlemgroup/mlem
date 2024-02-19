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
    // swiftlint:disable:next identifier_name
    let id: Int
    let modPersonId: Int
    let postId: Int
    let locked: Bool
    let when_: String
}
