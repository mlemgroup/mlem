//
//  FollowCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
            community_id: communityId,
            follow: follow
        )
    }
}
