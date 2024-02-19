//
//  APIModRemoveCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModRemoveCommentView.ts
struct APIModRemoveCommentView: Codable {
    let mod_remove_comment: APIModRemoveComment
    let moderator: APIPerson?
    let comment: APIComment
    let commenter: APIPerson
    let post: APIPost
    let community: APICommunity

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
