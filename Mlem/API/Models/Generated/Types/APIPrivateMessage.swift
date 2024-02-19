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
    // swiftlint:disable:next identifier_name
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
