//
//  APIPrivateMessageReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// PrivateMessageReport.ts
struct APIPrivateMessageReport: Codable {
    let id: Int
    let creatorId: Int
    let privateMessageId: Int
    let originalPmText: String
    let reason: String
    let resolved: Bool
    let resolverId: Int?
    let published: Date
    let updated: Date?
}
