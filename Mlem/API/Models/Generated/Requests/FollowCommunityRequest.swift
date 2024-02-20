//
//  FollowCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct FollowCommunityRequest: APIPostRequest {
    typealias Body = APIFollowCommunity
    typealias Response = APICommunityResponse

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
