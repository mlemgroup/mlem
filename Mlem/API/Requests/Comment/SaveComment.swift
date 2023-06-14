//
//  SaveComment.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023.
//

import Foundation

struct SaveCommentRequest: APIPutRequest {

    typealias Response = CommentResponse

    let instanceURL: URL
    let path = "comment/save"
    let body: Body

    // lemmy_api_common::comment::SaveComment
    struct Body: Encodable {
        let community_id: Int
        let save: Bool

        let auth: String
    }

    init(
        account: SavedAccount,

        commentId: Int,
        save: Bool
    ) {
        self.instanceURL = account.instanceLink

        self.body = .init(
            community_id: commentId,
            save: save,

            auth: account.accessToken
        )
    }
}
