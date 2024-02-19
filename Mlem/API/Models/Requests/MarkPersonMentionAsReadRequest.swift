//
//  MarkPersonMentionAsReadRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
            person_mention_id: personMentionId,
            read: read
        )
    }
}
