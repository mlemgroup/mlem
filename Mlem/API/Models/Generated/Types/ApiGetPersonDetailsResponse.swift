//
//  ApiGetPersonDetailsResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetPersonDetailsResponse.ts
struct ApiGetPersonDetailsResponse: Codable {
    let personView: ApiPersonView
    let comments: [ApiCommentView]
    let posts: [ApiPostView]
    let moderates: [ApiCommunityModeratorView]
    let site: ApiSite?
}
