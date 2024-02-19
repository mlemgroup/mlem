//
//  APILocalUserView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/LocalUserView.ts
struct APILocalUserView: Codable {
    let local_user: APILocalUser
    let person: APIPerson
    let counts: APIPersonAggregates
}
