//
//  BlockCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            communityId: communityId,
            block: block
        )
    }
}
