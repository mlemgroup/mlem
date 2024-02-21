//
//  TransferCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct TransferCommunityRequest: ApiPostRequest {
    typealias Body = ApiTransferCommunity
    typealias Response = ApiGetCommunityResponse

    let path = "/community/transfer"
    let body: Body?

    init(
        communityId: Int,
        personId: Int
    ) {
        self.body = .init(
            communityId: communityId,
            personId: personId
        )
    }
}
