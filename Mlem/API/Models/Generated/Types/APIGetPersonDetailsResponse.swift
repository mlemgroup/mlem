//
//  APIGetPersonDetailsResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPersonDetailsResponse.ts
struct APIGetPersonDetailsResponse: Codable {
    let personView: APIPersonView
    let site: APISite?
    let comments: [APICommentView]
    let posts: [APIPostView]
    let moderates: [APICommunityModeratorView]
}
