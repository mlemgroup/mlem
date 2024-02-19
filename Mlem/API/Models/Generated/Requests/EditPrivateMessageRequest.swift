//
//  EditPrivateMessageRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditPrivateMessageRequest: APIPutRequest {
    typealias Body = APIEditPrivateMessage
    typealias Response = APIPrivateMessageResponse

    let path = "/private_message"
    let body: Body?

    init(
        privateMessageId: Int,
        content: String
    ) {
        self.body = .init(
            private_message_id: privateMessageId,
            content: content
        )
    }
}
