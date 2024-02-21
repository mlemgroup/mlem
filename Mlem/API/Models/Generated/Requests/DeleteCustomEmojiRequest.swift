//
//  DeleteCustomEmojiRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct DeleteCustomEmojiRequest: ApiPostRequest {
    typealias Body = ApiDeleteCustomEmoji
    typealias Response = ApiSuccessResponse

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
