//
//  APISaveComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/SaveComment.ts
struct APISaveComment: Codable {
    let comment_id: Int
    let save: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "save", value: String(save))
        ]
    }
}
