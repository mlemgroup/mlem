//
//  APISavePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/SavePost.ts
struct APISavePost: Codable {
    let post_id: Int
    let save: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "post_id", value: String(post_id)),
            .init(name: "save", value: String(save))
        ]
    }
}
