//
//  APIModHideCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModHideCommunity.ts
struct APIModHideCommunity: Codable {
    let id: Int
    let communityId: Int
    let modPersonId: Int
    let when_: String
    let reason: String?
    let hidden: Bool
}
