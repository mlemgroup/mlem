//
//  MarkPrivateMessageAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation

struct MarkPrivateMessageAsRead: APIPostRequest {
    
    typealias Response = PrivateMessageResponse
    
    let instanceURL: URL
    let path = "private_message/mark_as_read"
    let body: Body
    
    struct Body: Encodable {
        let private_message_id: Int
        let read: Bool
        let auth: String
    }
    
    init(
        account: SavedAccount,
        privateMessageId: Int,
        read: Bool
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            private_message_id: privateMessageId,
            read: read,
            auth: account.accessToken
        )
    }
}

struct PrivateMessageResponse: Decodable {
    let privateMessageView: APIPrivateMessageView
}

// pub struct MarkPrivateMessageAsRead {
//   pub private_message_id: PrivateMessageId,
//   pub read: bool,
//   pub auth: Sensitive<String>,
// }
