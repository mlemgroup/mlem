//
//  APICommentReport.swift
//  Mlem
//
//  Created by Jake Shirley on 7/2/23.
//

import Foundation

// lemmy_db_schema::source::comment::CommentReport
struct APICommentReport: Hashable, Decodable {
    let id: Int
    let creatorId: Int
    let commentId: Int
    let originalCommentText: String
    let reason: String
    var resolved: Bool
    let resolverId: Int?
    let published: Date
    let updated: Date?
}
