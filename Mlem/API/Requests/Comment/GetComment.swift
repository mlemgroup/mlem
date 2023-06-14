//
//  GetComment.swift
//  Mlem
//
//  Created by Jonathan de Jong on 13.06.2023.
//

import Foundation

// lemmy_api_common::comment::
struct GetCommentRequest: APIGetRequest {

    typealias Response = CommentResponse

    let instanceURL: URL
    let path = "comment"
    let queryItems: [URLQueryItem]

    init(
        account: SavedAccount,

        id: Int
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "id", value: id.description),

            .init(name: "auth", value: account.accessToken),
        ]
    }

    init(
        instanceURL: URL,

        id: Int
    ) {
        self.instanceURL = instanceURL

        self.queryItems = [
            .init(name: "id", value: id.description)
        ]
    }
}
