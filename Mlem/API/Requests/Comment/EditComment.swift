//
//  EditComment.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023.
//

import Foundation

struct EditCommentRequest: APIPutRequest {

    typealias Response = CommentResponse

    let instanceURL: URL
    let path = "comment"
    let body: Body

    // lemmy_api_common::comment::EditComment
    struct Body: Encodable {
        let comment_id: Int
        let content: String?
        let distinguished: Bool?
        let language_id: Int?
        let form_id: String?

        let auth: String
    }

    init(
        account: SavedAccount,

        commentId: Int,
        content: String? = nil,
        distinguished: Bool? = nil,
        languageId: Int? = nil,
        formId: String? = nil
    ) {
        self.instanceURL = account.instanceLink

        self.body = .init(
            comment_id: commentId,
            content: content,
            distinguished: distinguished,
            language_id: languageId,
            form_id: formId,

            auth: account.accessToken
        )
    }
}
