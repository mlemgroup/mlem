//
//  PurgeCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PurgeCommunityRequest: ApiPostRequest {
    typealias Body = ApiPurgeCommunity
    typealias Response = ApiSuccessResponse

    let path = "/admin/purge/community"
    let body: Body?

    init(
        communityId: Int,
        reason: String?
    ) {
        self.body = .init(
            communityId: communityId,
            reason: reason
        )
    }
}
