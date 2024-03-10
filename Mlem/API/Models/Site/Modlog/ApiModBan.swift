//
//  ApiModBan.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModBan.ts
struct ApiModBan: Decodable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let reason: String?
    let banned: Bool
    let expires: String?
    let when_: String
}
