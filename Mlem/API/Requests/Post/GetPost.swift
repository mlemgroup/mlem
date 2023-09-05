//
//  GetPost.swift
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
    ) throws {
        self.instanceURL = try session.instanceUrl

        var queryItems: [URLQueryItem] = [
            .init(name: "id", value: id?.description),
            .init(name: "comment_id", value: commentId?.description)
        ]
        
        if let token = try? session.token {
            queryItems.append(
                .init(name: "auth", value: token)
            )
        }
        
        self.queryItems = queryItems
    }
}

// lemmy_api_common::post::GetPostResponse
struct GetPostResponse: Decodable {
    let postView: APIPostView
}
