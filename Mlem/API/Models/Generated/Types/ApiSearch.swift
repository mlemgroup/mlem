//
//  ApiSearch.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// Search.ts
struct ApiSearch: Codable {
    // swiftlint:disable:next identifier_name
    let q: String
    let communityId: Int?
    let communityName: String?
    let creatorId: Int?
    let type_: ApiSearchType?
    let sort: ApiSortType?
    let listingType: ApiListingType?
    let page: Int?
    let limit: Int?
}
