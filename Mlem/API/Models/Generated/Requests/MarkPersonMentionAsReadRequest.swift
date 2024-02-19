//
//  MarkPersonMentionAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct MarkPersonMentionAsReadRequest: APIPostRequest {
    typealias Body = APIMarkPersonMentionAsRead
    typealias Response = APIPersonMentionResponse

    let path = "/user/mention/mark_as_read"
    let body: Body?

    init(
        personMentionId: Int,
        read: Bool
    ) {
        self.body = .init(
            personMentionId: personMentionId,
            read: read
        )
    }
}
