//
//  GetPosts.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

// lemmy_api_common::post::GetPost
struct GetPostRequest: APIGetRequest {

    typealias Response = GetPostResponse

    let instanceURL: URL
    let path = "post"
    let queryItems: [URLQueryItem]

    init(
        session: APISession,
        id: Int?,
        commentId: Int?
    ) {
        self.instanceURL = session.URL

        self.queryItems = [
            .init(name: "auth", value: session.token),
            .init(name: "id", value: id?.description),
            .init(name: "comment_id", value: commentId?.description)
        ]
    }
}

// lemmy_api_common::post::GetPostResponse
struct GetPostResponse: Decodable {
    let postView: APIPostView
}
