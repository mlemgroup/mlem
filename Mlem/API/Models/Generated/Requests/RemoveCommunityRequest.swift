//
//  RemoveCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct RemoveCommunityRequest: APIPostRequest {
    typealias Body = APIRemoveCommunity
    typealias Response = APICommunityResponse

    let path = "/community/remove"
    let body: Body?

    init(
        communityId: Int,
        removed: Bool,
        reason: String?,
        expires: Int?
    ) {
        self.body = .init(
            communityId: communityId,
            removed: removed,
            reason: reason,
            expires: expires
        )
    }
}
