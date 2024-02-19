//
//  APIGetPrivateMessages.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/GetPrivateMessages.ts
struct APIGetPrivateMessages: Codable {
    let unreadOnly: Bool?
    let page: Int?
    let limit: Int?
    let creatorId: Int?
}
