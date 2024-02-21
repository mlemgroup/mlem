//
//  MarkPersonMentionAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct MarkPersonMentionAsReadRequest: ApiPostRequest {
    typealias Body = ApiMarkPersonMentionAsRead
    typealias Response = ApiPersonMentionResponse

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
