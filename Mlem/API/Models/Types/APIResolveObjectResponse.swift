//
//  APIResolveObjectResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ResolveObjectResponse.ts
struct APIResolveObjectResponse: Codable {
    let comment: APICommentView?
    let post: APIPostView?
    let community: APICommunityView?
    let person: APIPersonView?
}
