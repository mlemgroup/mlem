//
//  ApiAdminPurgeCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgeCommentView.ts
struct ApiAdminPurgeCommentView: Decodable {
    let adminPurgeComment: ApiAdminPurgeComment
    let admin: APIPerson?
    let post: APIPost
}
