//
//  ApiListCommunities.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ListCommunities.ts
struct ApiListCommunities: Codable {
    let type_: ApiListingType?
    let sort: ApiSortType?
    let showNsfw: Bool?
    let page: Int?
    let limit: Int?
}
