//
//  APIModBan.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModBan.ts
struct APIModBan: Decodable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let reason: String?
    let banned: Bool
    let expires: Date?
    let when_: Date
}
