//
//  APIRemoveCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/RemoveCommunity.ts
struct APIRemoveCommunity: Codable {
    let communityId: Int
    let removed: Bool
    let reason: String?
}
