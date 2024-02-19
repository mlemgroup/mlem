//
//  APIGetPersonDetailsResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetPersonDetailsResponse.ts
struct APIGetPersonDetailsResponse: Codable {
    let person_view: APIPersonView
    let site: APISite?
    let comments: [APICommentView]
    let posts: [APIPostView]
    let moderates: [APICommunityModeratorView]
}
