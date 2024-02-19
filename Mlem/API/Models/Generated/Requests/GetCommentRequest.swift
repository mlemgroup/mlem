//
//  GetCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetCommentRequest: APIGetRequest {
    typealias Response = APICommentResponse

    let path = "/comment"
    let queryItems: [URLQueryItem]

    init(
        id: Int
    ) {
        self.queryItems = [
            .init(name: "id", value: "\(id)")
        ]
    }
}
