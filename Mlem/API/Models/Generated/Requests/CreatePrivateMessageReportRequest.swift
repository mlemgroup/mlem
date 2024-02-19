//
//  CreatePrivateMessageReportRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct CreatePrivateMessageReportRequest: APIPostRequest {
    typealias Body = APICreatePrivateMessageReport
    typealias Response = APIPrivateMessageReportResponse

    let path = "/private_message/report"
    let body: Body?

    init(
        privateMessageId: Int,
        reason: String
    ) {
        self.body = .init(
            privateMessageId: privateMessageId,
            reason: reason
        )
    }
}
