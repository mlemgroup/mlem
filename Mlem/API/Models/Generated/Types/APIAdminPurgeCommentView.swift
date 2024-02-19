//
//  APIAdminPurgeCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/AdminPurgeCommentView.ts
struct APIAdminPurgeCommentView: Codable {
    let admin_purge_comment: APIAdminPurgeComment
    let admin: APIPerson?
    let post: APIPost
}
