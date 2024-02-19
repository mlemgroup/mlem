//
//  MarkPrivateMessageAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct MarkPrivateMessageAsReadRequest: APIPostRequest {
    typealias Body = APIMarkPrivateMessageAsRead
    typealias Response = APIPrivateMessageResponse

    let path = "/private_message/mark_as_read"
    let body: Body?

    init(
        privateMessageId: Int,
        read: Bool
    ) {
        self.body = .init(
            private_message_id: privateMessageId,
            read: read
        )
    }
}
