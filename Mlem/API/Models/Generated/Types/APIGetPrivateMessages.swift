//
//  APIGetPrivateMessages.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPrivateMessages.ts
struct APIGetPrivateMessages: Codable {
    let unreadOnly: Bool?
    let page: Int?
    let limit: Int?
    let creatorId: Int?
}
