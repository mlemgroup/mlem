//
//  APIListCommentReports.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ListCommentReports.ts
struct APIListCommentReports: Codable {
    let page: Int?
    let limit: Int?
    let unresolved_only: Bool?
    let community_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "unresolved_only", value: unresolved_only.map(String.init)),
            .init(name: "community_id", value: community_id.map(String.init))
        ]
    }
}
