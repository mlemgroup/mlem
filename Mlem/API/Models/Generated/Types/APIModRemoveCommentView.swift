//
//  APIModRemoveCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModRemoveCommentView.ts
struct APIModRemoveCommentView: Codable {
    let modRemoveComment: APIModRemoveComment
    let moderator: APIPerson?
    let comment: APIComment
    let commenter: APIPerson
    let post: APIPost
    let community: APICommunity
}
