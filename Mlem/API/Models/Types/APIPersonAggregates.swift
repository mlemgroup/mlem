//
//  APIPersonAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PersonAggregates.ts
struct APIPersonAggregates: Codable {
    let person_id: Int
    let post_count: Int
    let comment_count: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "person_id", value: String(person_id)),
            .init(name: "post_count", value: String(post_count)),
            .init(name: "comment_count", value: String(comment_count))
        ]
    }
}
