//
//  MarkPersonMentionAsReadRequest.swift
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
        session: APISession,
        personMentionId: Int,
        read: Bool
    ) {
        self.instanceURL = session.URL
        self.body = .init(
            person_mention_id: personMentionId,
            read: read,
            auth: session.token
        )
    }
}

struct PersonMentionResponse: Decodable {
    let personMentionView: APIPersonMentionView
}
