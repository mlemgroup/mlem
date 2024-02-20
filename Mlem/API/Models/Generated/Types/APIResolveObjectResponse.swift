//
//  APIResolveObjectResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ResolveObjectResponse.ts
struct APIResolveObjectResponse: Codable {
    let comment: APICommentView?
    let post: APIPostView?
    let community: APICommunityView?
    let person: APIPersonView?
}
