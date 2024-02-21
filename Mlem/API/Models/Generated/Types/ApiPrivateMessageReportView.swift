//
//  ApiPrivateMessageReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// PrivateMessageReportView.ts
struct ApiPrivateMessageReportView: Codable {
    let privateMessageReport: ApiPrivateMessageReport
    let privateMessage: ApiPrivateMessage
    let privateMessageCreator: ApiPerson
    let creator: ApiPerson
    let resolver: ApiPerson?
}
