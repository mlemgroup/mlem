//
//  GetCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetCommentRequest: ApiGetRequest {
    typealias Response = ApiCommentResponse

    let path = "/comment"
    let queryItems: [URLQueryItem]

    init(
        id: Int
    ) {
        self.queryItems = [
            .init(name: "id", value: String(id))
        ]
    }
}
