//
//  APIGetPersonMentions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetPersonMentions.ts
struct APIGetPersonMentions: Codable {
    let sort: APICommentSortType?
    let page: Int?
    let limit: Int?
    let unread_only: Bool?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
