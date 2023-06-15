//
//  SavePost.swift
//  Mlem
//
//  Created by Jonathan de Jong on 13.06.2023.
//

import Foundation

struct SavePostRequest: APIPutRequest {

    typealias Response = PostResponse

    let instanceURL: URL
    let path = "post/save"
    let body: Body

    // lemmy_api_common::post::SavePost
    struct Body: Encodable {
        let post_id: Int
        let save: Bool

        let auth: String
    }

    init(
        account: SavedAccount,

        postId: Int,
        save: Bool
    ) {
        self.instanceURL = account.instanceLink

        self.body = .init(
            post_id: postId,
            save: save,

            auth: account.accessToken
        )
    }
}
