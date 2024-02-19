//
//  APIPrivateMessageReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/PrivateMessageReport.ts
struct APIPrivateMessageReport: Codable {
    // swiftlint:disable:next identifier_name
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
