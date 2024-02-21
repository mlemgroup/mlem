//
//  ApiPrivateMessage.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// PrivateMessage.ts
struct ApiPrivateMessage: Codable {
    let id: Int
    let creatorId: Int
    let recipientId: Int
    let content: String
    let deleted: Bool
    let read: Bool
    let published: Date
    let updated: Date?
    let apId: URL
    let local: Bool
}
