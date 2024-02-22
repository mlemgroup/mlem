//
//  ApiModRemoveCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModRemoveCommentView.ts
struct ApiModRemoveCommentView: Codable {
    let modRemoveComment: ApiModRemoveComment
    let moderator: ApiPerson?
    let comment: ApiComment
    let commenter: ApiPerson
    let post: ApiPost
    let community: ApiCommunity
}
