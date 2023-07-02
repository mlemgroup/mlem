//
//  MarkMentionAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation

struct MarkPersonMentionAsRead: APIPostRequest {
    
    typealias Response = PersonMentionResponse
    
    let instanceURL: URL
    let path = "user/mention/mark_as_read"
    let body: Body
    
    struct Body: Encodable {
        let person_mention_id: Int
        let read: Bool
        let auth: String
    }
    
    init(
        account: SavedAccount,
        personMentionId: Int,
        read: Bool
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            person_mention_id: personMentionId,
            read: read,
            auth: account.accessToken
        )
    }
}

struct PersonMentionResponse: Decodable {
    let personMentionView: APIPersonMentionView
}

// pub struct MarkPersonMentionAsRead {
//   pub person_mention_id: PersonMentionId,
//   pub read: bool,
//   pub auth: Sensitive<String>,
// }
