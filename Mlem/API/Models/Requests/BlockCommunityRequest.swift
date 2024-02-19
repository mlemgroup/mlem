//
//  BlockCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct BlockCommunityRequest: APIPostRequest {
    typealias Body = APIBlockCommunity
    typealias Response = APIBlockCommunityResponse

    let path = "/community/block"
    let body: Body?

    init(
        communityId: Int,
        block: Bool
    ) {
        self.body = .init(
            community_id: communityId,
            block: block
        )
    }
}
