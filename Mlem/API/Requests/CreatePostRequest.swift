//
//  CreatePostRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct CreatePostRequest: APIRequest {
    
    typealias Response = CreatePostResponse
    
    let endpoint: URL
    let method: HTTPMethod
    
    struct Body: Encodable {
        let auth: String
        let community_id: Int
        let name: String
        let nsfw: Bool?
        let body: String?
        let url: URL?
    }
    
    init(
        account: SavedAccount,
        communityId: Int,
        name: String,
        nsfw: Bool?,
        body: String?,
        url: String?
    ) throws {
        do {
            let data = try JSONEncoder().encode(
                Body(
                    auth: account.accessToken,
                    community_id: communityId,
                    name: name,
                    nsfw: nsfw,
                    body: body,
                    // TODO: some work is needed here as the current UI implementation
                    // always passes an empty String, which if encoded directly will cause the request to fail
                    // however if user enters a "valid" URL such as `beehaw.org` the request will also fail
                    // as the API wants a fully formed URL. Some discussion is needed to decide how to handle
                    // this, and at what level that handling should occur.
                    url: URL(string: url ?? "")
                )
            )
            self.endpoint = account.instanceLink
                .appending(path: "post")
            self.method = .post(data)
        } catch {
            throw APIRequestError.encoding
        }
    }
}

struct CreatePostResponse: Decodable {
    let postView: APIPostView
}
