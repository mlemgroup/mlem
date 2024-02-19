//
//  PurgeCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PurgeCommunityRequest: APIPostRequest {
    typealias Body = APIPurgeCommunity
    typealias Response = APISuccessResponse

    let path = "/admin/purge/community"
    let body: Body?

    init(
        communityId: Int,
        reason: String?
    ) {
        self.body = .init(
            community_id: communityId,
            reason: reason
        )
    }
}
