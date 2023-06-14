//
//  CreatePost.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct CreatePostRequest: APIPostRequest {

    typealias Response = PostResponse

    let instanceURL: URL
    let path = "post"
    let body: Body

    // lemmy_api_common::post::CreatePost
    struct Body: Encodable {
        // missing: honeypot field
        let auth: String
        let community_id: Int
        let name: String
        let nsfw: Bool?
        let body: String?
        let language_id: Int?
        let url: URL?
    }

    init(
        account: SavedAccount,
        communityId: Int,
        name: String,
        nsfw: Bool?,
        body: String?,
        // TODO change to `URL?`
        url: String?
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
                auth: account.accessToken,
                community_id: communityId,
                name: name,
                nsfw: nsfw,
                body: body,
                // TODO add to init params
                language_id: nil,
                // TODO: some work is needed here as the current UI implementation
                // always passes an empty String, which if encoded directly will cause the request to fail
                // however if user enters a "valid" URL such as `beehaw.org` the request will also fail
                // as the API wants a fully formed URL. Some discussion is needed to decide how to handle
                // this, and at what level that handling should occur.
                url: URL(string: url ?? "")
            )
    }
}

// lemmy_api_common::post::PostResponse
struct PostResponse: Decodable {
    let postView: APIPostView
}
