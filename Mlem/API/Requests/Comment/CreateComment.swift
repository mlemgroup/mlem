//
//  CreateComment.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct CreateCommentRequest: APIPostRequest {

    typealias Response = CommentResponse

    let instanceURL: URL
    let path = "comment"
    let body: Body

    // lemmy_api_common::comment::CreateComment
    struct Body: Encodable {
        let content: String
        let post_id: Int
        let parent_id: Int?
        let language_id: Int?
        let form_id: String?
        let auth: String
    }

    init(
        account: SavedAccount,
        content: String,
        languageId: Int?,
        parentId: Int?,
        postId: Int
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            content: content,
            post_id: postId,
            parent_id: parentId,
            language_id: languageId,
            form_id: nil,
            auth: account.accessToken
        )
    }
}

// lemmy_api_common::comment::CommentResponse
struct CommentResponse: Decodable {
    let commentView: APICommentView
    let recipientIds: [Int]
    let formId: String?
}
