//
//  APIPrivateMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/PrivateMessage.ts
struct APIPrivateMessage: Codable {
    let id: Int
    let creator_id: Int
    let recipient_id: Int
    let content: String
    let deleted: Bool
    let read: Bool
    let published: Date
    let updated: Date?
    let ap_id: URL
    let local: Bool
}
