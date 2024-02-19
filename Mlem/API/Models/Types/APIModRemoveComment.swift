//
//  APIModRemoveComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModRemoveComment.ts
struct APIModRemoveComment: Codable {
    let id: Int
    let mod_person_id: Int
    let comment_id: Int
    let reason: String?
    let removed: Bool
    let when_: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "mod_person_id", value: String(mod_person_id)),
            .init(name: "comment_id", value: String(comment_id)),
            .init(name: "reason", value: reason),
            .init(name: "removed", value: String(removed)),
            .init(name: "when_", value: when_)
        ]
    }
}
