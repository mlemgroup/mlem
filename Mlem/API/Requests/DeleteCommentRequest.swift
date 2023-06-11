//
//  DeleteCommentRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct DeleteCommentRequest: APIPostRequest {
    
    typealias Response = CreateCommentResponse
    
    let instanceURL: URL
    let path = "comment/delete"
    let body: Body
    
    struct Body: Encodable {
        let auth: String
        let comment_id: Int
        let deleted: Bool
    }
    
    init(
        account: SavedAccount,
        commentId: Int,
        deleted: Bool = true
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            auth: account.accessToken,
            comment_id: commentId,
            deleted: deleted
        )
    }
}

