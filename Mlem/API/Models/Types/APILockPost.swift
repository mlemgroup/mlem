//
//  APILockPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/LockPost.ts
struct APILockPost: Codable {
    let post_id: Int
    let locked: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "post_id", value: String(post_id)),
            .init(name: "locked", value: String(locked))
        ]
    }
}
