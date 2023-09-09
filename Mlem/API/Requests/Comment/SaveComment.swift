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
        let comment_id: Int
        let save: Bool

        let auth: String
    }

    init(
        session: APISession,

        commentId: Int,
        save: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl

        self.body = try .init(
            comment_id: commentId,
            save: save,
            auth: session.token
        )
    }
}
