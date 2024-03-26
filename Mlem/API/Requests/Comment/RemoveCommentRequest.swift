//
//  RemoveCommentRequest.swift
//  Mlem
//
//  Created by Sjmarf on 22/03/2024.
//

import Foundation

struct RemoveCommentRequest: APIPostRequest {
    typealias Response = CommentResponse
    
    var instanceURL: URL
    let path = "comment/remove"
    let body: Body
    
    struct Body: Codable {
        let comment_id: Int
        let removed: Bool
        let reason: String?
        let auth: String
    }
    
    init(
        session: APISession,
        commentId: Int,
        removed: Bool,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            comment_id: commentId,
            removed: removed,
            reason: reason,
            auth: session.token
        )
    }
}
