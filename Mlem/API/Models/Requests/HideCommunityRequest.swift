//
//  HideCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct HideCommunityRequest: APIPutRequest {
    typealias Body = APIHideCommunity
    typealias Response = APISuccessResponse

    let path = "/community/hide"
    let body: Body?

    init(
        communityId: Int,
        hidden: Bool,
        reason: String
    ) {
        self.body = .init(
            community_id: communityId,
            hidden: hidden,
            reason: reason
        )
    }
}
