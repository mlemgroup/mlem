//
//  APIGetUnreadCountResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetUnreadCountResponse.ts
struct APIGetUnreadCountResponse: Codable {
    let replies: Int
    let mentions: Int
    let privateMessages: Int
}
