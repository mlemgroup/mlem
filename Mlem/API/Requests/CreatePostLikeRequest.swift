//
//  CreatePostLikeRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct CreatePostLikeRequest: APIRequest {
    
    typealias Response = CreatePostLikeResponse
    
    let endpoint: URL
    let method: HTTPMethod
    
    struct Body: Encodable {
        let auth: String
        let post_id: Int
        let score: Int
    }
    
    init(
        account: SavedAccount,
        postId: Int,
        score: ScoringOperation
    ) throws {
        do {
            let data = try JSONEncoder().encode(
                Body(
                    auth: account.accessToken,
                    post_id: postId,
                    score: score.rawValue
                )
            )
            self.endpoint = account.instanceLink
                .appending(path: "post")
                .appending(path: "like")
            
            self.method = .post(data)
        } catch {
            throw APIRequestError.encoding
        }
    }
}

struct CreatePostLikeResponse: Decodable {
    let postView: APIPostView
}
