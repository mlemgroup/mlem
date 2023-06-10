//
//  DeleteCommentRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct DeleteCommentRequest: APIRequest {
    
    typealias Response = CreateCommentResponse
    
    let endpoint: URL
    let method: HTTPMethod
    
    struct Body: Encodable {
        let auth: String
        let comment_id: Int
        let deleted: Bool
    }
    
    init(
        account: SavedAccount,
        commentId: Int,
        deleted: Bool = true
    ) throws {
        do {
            let data = try JSONEncoder().encode(
                Body(
                    auth: account.accessToken,
                    comment_id: commentId,
                    deleted: deleted
                )
            )
            self.endpoint = account.instanceLink
                .appending(path: "comment")
                .appending(path: "delete")
            self.method = .post(data)
        } catch {
            throw APIRequestError.encoding
        }
    }
}

