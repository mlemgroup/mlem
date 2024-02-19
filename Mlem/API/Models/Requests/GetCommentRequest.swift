//
//  GetCommentRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct GetCommentRequest: APIGetRequest {
    typealias Response = APICommentResponse

    let path = "/comment"
    let queryItems: [URLQueryItem]

    init(
        id: Int
    ) {
        var request: APIGetComment = .init(
            id: id
        )
        self.queryItems = request.toQueryItems()
    }
}
