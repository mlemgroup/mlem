//
//  APIGetPersonMentions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPersonMentions.ts
struct APIGetPersonMentions: Codable {
    let sort: APICommentSortType?
    let page: Int?
    let limit: Int?
    let unreadOnly: Bool?
}
