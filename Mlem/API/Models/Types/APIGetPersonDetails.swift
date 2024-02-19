//
//  APIGetPersonDetails.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetPersonDetails.ts
struct APIGetPersonDetails: Codable {
    let person_id: Int?
    let username: String?
    let sort: APISortType?
    let page: Int?
    let limit: Int?
    let community_id: Int?
    let saved_only: Bool?

    func toQueryItems() -> [URLQueryItem] {
        return [

        ]
    }

}
