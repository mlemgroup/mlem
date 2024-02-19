//
//  APISearch.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/Search.ts
struct APISearch: Codable {
    // swiftlint:disable:next identifier_name
    let q: String
    let community_id: Int?
    let community_name: String?
    let creator_id: Int?
    let type_: APISearchType?
    let sort: APISortType?
    let listing_type: APIListingType?
    let page: Int?
    let limit: Int?
}
