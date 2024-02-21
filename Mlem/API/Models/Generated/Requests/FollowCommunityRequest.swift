//
//  FollowCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct FollowCommunityRequest: ApiPostRequest {
    typealias Body = ApiFollowCommunity
    typealias Response = ApiCommunityResponse

    let path = "/community/follow"
    let body: Body?

    init(
        communityId: Int,
        follow: Bool
    ) {
        self.body = .init(
            communityId: communityId,
            follow: follow
        )
    }
}
