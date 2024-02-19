//
//  TransferCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct TransferCommunityRequest: APIPostRequest {
    typealias Body = APITransferCommunity
    typealias Response = APIGetCommunityResponse

    let path = "/community/transfer"
    let body: Body?

    init(
        communityId: Int,
        personId: Int
    ) {
        self.body = .init(
            community_id: communityId,
            person_id: personId
        )
    }
}
