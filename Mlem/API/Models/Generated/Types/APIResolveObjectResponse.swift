//
//  APIResolveObjectResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ResolveObjectResponse.ts
struct APIResolveObjectResponse: Codable {
    let comment: APICommentView?
    let post: APIPostView?
    let community: APICommunityView?
    let person: APIPersonView?
}
