//
//  ListPostLikesRequest.swift
//  Mlem
//
//  Created by Sjmarf on 22/03/2024.
//

import Foundation

struct ListPostLikesRequest: APIGetRequest {
    typealias Response = APIListPostLikesResponse

    var instanceURL: URL
    let path = "post/like/list"
    let queryItems: [URLQueryItem]

    init(
        session: APISession,
        postId: Int,
        page: Int?,
        limit: Int?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = try [
            .init(name: "auth", value: session.token),
            .init(name: "post_id", value: String(postId)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init))
        ]
    }
}

struct APIVoteView: Decodable {
    let creator: APIPerson
    
    // Not in a live version yet as of the time of writing, but was merged in https://github.com/LemmyNet/lemmy/pull/4568
    let creatorBannedFromCommunity: Bool?
    
    let score: ScoringOperation
}

struct APIListPostLikesResponse: Decodable {
    let postLikes: [APIVoteView]
}
