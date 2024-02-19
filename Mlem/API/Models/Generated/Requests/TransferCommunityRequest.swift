//
//  TransferCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
