//
//  CreatePrivateMessageReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-12.
//

import Foundation

struct CreatePrivateMessageReportRequest: APIPostRequest {

    typealias Response = CreatePrivateMessageReportResponse

    let instanceURL: URL
    let path = "private_message/report"
    let body: Body

    // lemmy_api_common::post::CreatePostReport
    struct Body: Encodable {
        let auth: String
        let private_message_id: Int
        let reason: String
    }

    init(
        session: APISession,
        privateMessageId: Int,
        reason: String
    ) {
        self.instanceURL = session.URL
        self.body = .init(auth: session.token, private_message_id: privateMessageId, reason: reason)
    }
}

// lemmy_api_common::comment::CreateCommentReportRequest
struct CreatePrivateMessageReportResponse: Decodable {
    let privateMessageReportView: APIPrivateMessageReportView
}
