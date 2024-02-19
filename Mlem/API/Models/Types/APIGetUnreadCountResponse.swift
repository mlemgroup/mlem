//
//  APIGetUnreadCountResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetUnreadCountResponse.ts
struct APIGetUnreadCountResponse: Codable {
    let replies: Int
    let mentions: Int
    let private_messages: Int
}
