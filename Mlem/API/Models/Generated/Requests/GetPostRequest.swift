//
//  GetPostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetPostRequest: APIGetRequest {
    typealias Response = APIGetPostResponse

    let path = "/post"
    let queryItems: [URLQueryItem]

    init(
        id: Int?,
        commentId: Int?
    ) {
        self.queryItems = [
            .init(name: "id", value: "\(id)"),
            .init(name: "comment_id", value: "\(commentId)")
        ]
    }
}
