//
//  HideCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct HideCommunityRequest: APIPutRequest {
    typealias Body = APIHideCommunity
    typealias Response = APISuccessResponse

    let path = "/community/hide"
    let body: Body?

    init(
        communityId: Int,
        hidden: Bool,
        reason: String?
    ) {
        self.body = .init(
            communityId: communityId,
            hidden: hidden,
            reason: reason
        )
    }
}
