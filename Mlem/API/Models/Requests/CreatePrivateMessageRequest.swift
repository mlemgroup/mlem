//
//  CreatePrivateMessageRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct CreatePrivateMessageRequest: APIPostRequest {
    typealias Body = APICreatePrivateMessage
    typealias Response = APIPrivateMessageResponse

    let path = "/private_message"
    let body: Body?

    init(
        content: String,
        recipientId: Int
    ) {
        self.body = .init(
            content: content,
            recipient_id: recipientId
        )
    }
}
