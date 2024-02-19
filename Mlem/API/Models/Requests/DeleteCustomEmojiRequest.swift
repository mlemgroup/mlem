//
//  DeleteCustomEmojiRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct DeleteCustomEmojiRequest: APIPostRequest {
    typealias Body = APIDeleteCustomEmoji
    typealias Response = APISuccessResponse

    let path = "/custom_emoji/delete"
    let body: Body?

    init(
        id: Int
    ) {
        self.body = .init(
            id: id
        )
    }
}
