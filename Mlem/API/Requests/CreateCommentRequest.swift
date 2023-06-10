//
//  CreateCommentRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct CreateCommentRequest: APIRequest {
    
    typealias Response = CreateCommentResponse
    
    let endpoint: URL
    let method: HTTPMethod
    
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
    ) throws {
        do {
            let data = try JSONEncoder().encode(
                Body(
                    auth: account.accessToken,
                    content: content,
                    form_id: nil,
                    language_id: languageId,
                    parent_id: parentId,
                    post_id: postId
                )
            )
            self.endpoint = account.instanceLink
                .appending(path: "comment")
            self.method = .post(data)
        } catch {
            throw APIRequestError.encoding
        }
    }
}

struct CreateCommentResponse: Decodable {
    let commentView: APICommentView
}
