//
//  APIModAddCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModAddCommunity.ts
struct APIModAddCommunity: Codable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let communityId: Int
    let removed: Bool
    let when_: String
}
