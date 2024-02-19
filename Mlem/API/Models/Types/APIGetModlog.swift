//
//  APIGetModlog.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetModlog.ts
struct APIGetModlog: Codable {
    let mod_person_id: Int?
    let community_id: Int?
    let page: Int?
    let limit: Int?
    let type_: APIModlogActionType?
    let other_person_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
