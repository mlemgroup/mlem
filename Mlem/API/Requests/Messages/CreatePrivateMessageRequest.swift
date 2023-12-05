//
//  CreatePrivateMessageRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation

struct CreatePrivateMessageRequest: APIPostRequest {
    typealias Response = PrivateMessageResponse

    let instanceURL: URL
    let path = "private_message"
    let body: Body

    // lemmy_api_common::post::CreatePrivateMessage
    struct Body: Encodable {
        let auth: String
        let content: String
        let recipient_id: Int
    }

    init(
        session: APISession,
        content: String,
        recipientId: Int
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(auth: session.token, content: content, recipient_id: recipientId)
    }

    @available(*, deprecated, message: "Use id-based initializer instead")
    init(
        session: APISession,
        content: String,
        recipient: APIPerson
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(auth: session.token, content: content, recipient_id: recipient.id)
    }
}
