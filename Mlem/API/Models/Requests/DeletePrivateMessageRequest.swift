//
//  DeletePrivateMessageRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct DeletePrivateMessageRequest: APIPostRequest {
    typealias Body = APIDeletePrivateMessage
    typealias Response = APIPrivateMessageResponse

    let path = "/private_message/delete"
    let body: Body?

    init(
        privateMessageId: Int,
        deleted: Bool
    ) {
        self.body = .init(
            private_message_id: privateMessageId,
            deleted: deleted
        )
    }
}
