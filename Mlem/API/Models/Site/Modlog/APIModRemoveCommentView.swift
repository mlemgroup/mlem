//
//  APIModRemoveCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemoveCommentView.ts
struct APIModRemoveCommentView: Decodable {
    let modRemoveComment: APIModRemoveComment
    let moderator: APIPerson?
    let comment: APIComment
    let commenter: APIPerson
    let post: APIPost
    let community: APICommunity
}
