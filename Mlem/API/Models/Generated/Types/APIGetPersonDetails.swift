//
//  APIGetPersonDetails.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/GetPersonDetails.ts
struct APIGetPersonDetails: Codable {
    let personId: Int?
    let username: String?
    let sort: APISortType?
    let page: Int?
    let limit: Int?
    let communityId: Int?
    let savedOnly: Bool?
}
