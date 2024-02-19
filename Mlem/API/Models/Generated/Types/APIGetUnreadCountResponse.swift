//
//  APIGetUnreadCountResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/GetUnreadCountResponse.ts
struct APIGetUnreadCountResponse: Codable {
    let replies: Int
    let mentions: Int
    let private_messages: Int
}
