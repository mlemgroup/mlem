//
//  ApiModHideCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModHideCommunity.ts
struct ApiModHideCommunity: Codable {
    let id: Int
    let community_id: Int
    let mod_person_id: Int
    let when_: String
    let reason: String?
    let hidden: Bool
}
