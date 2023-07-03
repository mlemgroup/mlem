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

    // lemmy_api_common::post::CreatePostLike
    struct Body: Encodable {
        let auth: String
        let content: String
        let recipient_id: Int
    }

    init(
        account: SavedAccount,
        content: String,
        recipient: APIPerson
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(auth: account.accessToken, content: content, recipient_id: recipient.id)
    }
}

// pub struct CreatePrivateMessage {
//   pub content: String,
//   pub recipient_id: PersonId,
//   pub auth: Sensitive<String>,
// }
