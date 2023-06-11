//
//  CreateCommentLikeRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct CreateCommentLikeRequest: APIPostRequest {
    
    typealias Response = CreateCommentLikeResponse
    
    let instanceURL: URL
    let path = "comment/like"
    let body: Body
    
    struct Body: Encodable {
        let auth: String
        let comment_id: Int
        let score: Int
    }
    
    init(
        account: SavedAccount,
        commentId: Int,
        score: ScoringOperation
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            auth: account.accessToken,
            comment_id: commentId,
            score: score.rawValue
        )
    }
}

struct CreateCommentLikeResponse: Decodable {
    let commentView: APICommentView
}
