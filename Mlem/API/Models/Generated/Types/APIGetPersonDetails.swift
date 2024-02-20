//
//  APIGetPersonDetails.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPersonDetails.ts
struct APIGetPersonDetails: Codable {
    let personId: Int?
    let username: String?
    let sort: APISortType?
    let page: Int?
    let limit: Int?
    let communityId: Int?
    let savedOnly: Bool?
}
