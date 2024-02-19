//
//  APIGetPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetPost.ts
struct APIGetPost: Codable {
    let id: Int?
    let comment_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "id", value: id.map(String.init)),
            .init(name: "comment_id", value: comment_id.map(String.init))
        ]
    }

}
