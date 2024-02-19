//
//  APIPrivateMessageReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PrivateMessageReportView.ts
struct APIPrivateMessageReportView: Codable {
    let private_message_report: APIPrivateMessageReport
    let private_message: APIPrivateMessage
    let private_message_creator: APIPerson
    let creator: APIPerson
    let resolver: APIPerson?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
