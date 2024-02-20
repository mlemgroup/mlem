//
//  DeletePrivateMessageRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            privateMessageId: privateMessageId,
            deleted: deleted
        )
    }
}
