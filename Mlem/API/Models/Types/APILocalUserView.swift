//
//  APILocalUserView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/LocalUserView.ts
struct APILocalUserView: Codable {
    let local_user: APILocalUser
    let person: APIPerson
    let counts: APIPersonAggregates

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
