//
//  APISearch.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// Search.ts
struct APISearch: Codable {
    // swiftlint:disable:next identifier_name
    let q: String
    let communityId: Int?
    let communityName: String?
    let creatorId: Int?
    let type_: APISearchType?
    let sort: APISortType?
    let listingType: APIListingType?
    let page: Int?
    let limit: Int?
}
