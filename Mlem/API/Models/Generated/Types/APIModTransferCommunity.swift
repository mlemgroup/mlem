//
//  APIModTransferCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModTransferCommunity.ts
struct APIModTransferCommunity: Codable {
    let id: Int
    let mod_person_id: Int
    let other_person_id: Int
    let community_id: Int
    let when_: String
}
