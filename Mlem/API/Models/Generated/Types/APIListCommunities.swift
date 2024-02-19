//
//  APIListCommunities.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ListCommunities.ts
struct APIListCommunities: Codable {
    let type_: APIListingType?
    let sort: APISortType?
    let showNsfw: Bool?
    let page: Int?
    let limit: Int?
}
