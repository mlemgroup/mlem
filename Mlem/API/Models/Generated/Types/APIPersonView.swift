//
//  APIPersonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/PersonView.ts
struct APIPersonView: Codable {
    let person: APIPerson
    let counts: APIPersonAggregates
    let isAdmin: Bool
}
