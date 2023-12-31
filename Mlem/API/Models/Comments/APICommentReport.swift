//
//  APICommentReport.swift
//  Mlem
//
//  Created by Jake Shirley on 7/2/23.
//

import Foundation

// lemmy_db_schema::source::comment::CommentReport
struct APICommentReport: Decodable {
    let id: Int
    let creatorId: Int
    let commentId: Int
    let originalCommentText: String
    let reason: String
    let resolved: Bool
    let resolverId: Int?
    let published: Date
    let updated: Date?
}
