//
//  APIAdminPurgeCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgeCommentView.ts
struct APIAdminPurgeCommentView: Decodable {
    let adminPurgeComment: APIAdminPurgeComment
    let admin: APIPerson?
    let post: APIPost
}
