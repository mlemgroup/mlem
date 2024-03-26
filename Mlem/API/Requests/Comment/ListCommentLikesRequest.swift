//
//  ListCommentLikesRequest.swift
//  Mlem
//
//  Created by Sjmarf on 25/03/2024.
//

import Foundation

struct ListCommentLikesRequest: APIGetRequest {
    typealias Response = APIListCommentLikesResponse

    var instanceURL: URL
    let path = "comment/like/list"
    let queryItems: [URLQueryItem]

    init(
        session: APISession,
        commentId: Int,
        page: Int?,
        limit: Int?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = [
            .init(name: "auth", value: try session.token),
            .init(name: "comment_id", value: String(commentId)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init))
        ]
    }
}

struct APIListCommentLikesResponse: Decodable {
    let commentLikes: [APIVoteView]
}
