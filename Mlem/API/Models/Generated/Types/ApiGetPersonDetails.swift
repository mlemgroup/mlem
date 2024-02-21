//
//  ApiGetPersonDetails.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPersonDetails.ts
struct ApiGetPersonDetails: Codable {
    let personId: Int?
    let username: String?
    let sort: ApiSortType?
    let page: Int?
    let limit: Int?
    let communityId: Int?
    let savedOnly: Bool?
}
