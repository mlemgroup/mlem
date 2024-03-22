//
//  PurgeCommentRequest.swift
//  Mlem
//
//  Created by Sjmarf on 22/03/2024.
//

import Foundation

struct PurgeCommentRequest: APIPostRequest {
    typealias Response = SuccessResponse

    var instanceURL: URL
    let path = "admin/purge/comment"
    let body: Body
    
    struct Body: Codable {
        let comment_id: Int
        let reason: String?
    }

    init(
        session: APISession,
        commentId: Int,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = .init(
          comment_id: commentId,
          reason: reason
      )
    }
}
