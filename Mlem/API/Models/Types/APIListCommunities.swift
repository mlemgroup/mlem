//
//  APIListCommunities.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ListCommunities.ts
struct APIListCommunities: Codable {
    let type_: APIListingType?
    let sort: APISortType?
    let show_nsfw: Bool?
    let page: Int?
    let limit: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
