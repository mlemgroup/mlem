//
//  APIPrivateMessageReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/PrivateMessageReportView.ts
struct APIPrivateMessageReportView: Codable {
    let privateMessageReport: APIPrivateMessageReport
    let privateMessage: APIPrivateMessage
    let privateMessageCreator: APIPerson
    let creator: APIPerson
    let resolver: APIPerson?
}
