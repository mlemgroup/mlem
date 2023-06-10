//
//  CreateCommentLikeRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct CreateCommentLikeRequest: APIRequest {
    
    typealias Response = CreateCommentLikeResponse
    
    let endpoint: URL
    let method: HTTPMethod
    
    struct Body: Encodable {
        let auth: String
        let comment_id: Int
        let score: Int
    }
    
    init(
        account: SavedAccount,
        commentId: Int,
        score: ScoringOperation
    ) throws {
        do {
            let data = try JSONEncoder().encode(
                Body(
                    auth: account.accessToken,
                    comment_id: commentId,
                    score: score.rawValue
                )
            )
            self.endpoint = account.instanceLink
                .appending(path: "comment")
                .appending(path: "like")
            
            self.method = .post(data)
        } catch {
            throw APIRequestError.encoding
        }
    }
}

struct CreateCommentLikeResponse: Decodable {
    let commentView: APICommentView
}
