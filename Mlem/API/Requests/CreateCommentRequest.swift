//
//  CreateCommentRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct CreateCommentRequest: APIPostRequest {
    
    typealias Response = CreateCommentResponse
    
    let instanceURL: URL
    let path = "comment"
    let body: Body
    
    struct Body: Encodable {
        let auth: String
        let content: String
        let form_id: String?
        let language_id: Int?
        let parent_id: Int?
        let post_id: Int
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
            auth: account.accessToken,
            content: content,
            form_id: nil,
            language_id: languageId,
            parent_id: parentId,
            post_id: postId
        )
    }
}

struct CreateCommentResponse: Decodable {
    let commentView: APICommentView
}
