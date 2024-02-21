//
//  BlockCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct BlockCommunityRequest: ApiPostRequest {
    typealias Body = ApiBlockCommunity
    typealias Response = ApiBlockCommunityResponse

    let path = "/community/block"
    let body: Body?

    init(
        communityId: Int,
        block: Bool
    ) {
        self.body = .init(
            communityId: communityId,
            block: block
        )
    }
}
