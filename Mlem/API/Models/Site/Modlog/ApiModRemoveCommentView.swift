//
//  ApiModRemoveCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemoveCommentView.ts
struct ApiModRemoveCommentView: Decodable {
    let mod_remove_comment: ApiModRemoveComment
    let moderator: APIPerson?
    let comment: APIComment
    let commenter: APIPerson
    let post: APIPost
    let community: APICommunity
}
