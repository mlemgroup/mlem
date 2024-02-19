//
//  APIListPostLikes.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ListPostLikes.ts
struct APIListPostLikes: Codable {
    let post_id: Int
    let page: Int?
    let limit: Int?

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "post_id", value: String(post_id)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init))
        ]
    }

}
