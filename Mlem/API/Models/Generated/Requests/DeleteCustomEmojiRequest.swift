//
//  DeleteCustomEmojiRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
