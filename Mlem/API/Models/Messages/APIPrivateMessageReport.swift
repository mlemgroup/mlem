//
//  APIPrivateMessageReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-12.
//

import Foundation

// crates/db_schema/src/source/private_message_report.rs PrivateMessageReport
struct APIPrivateMessageReport: Decodable {
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
