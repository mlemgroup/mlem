//
//  BanFromCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct BanFromCommunityRequest: APIPostRequest {
    typealias Body = APIBanFromCommunity
    typealias Response = APIBanFromCommunityResponse

    let path = "/community/ban_user"
    let body: Body?

    init(
        communityId: Int,
        personId: Int,
        ban: Bool,
        removeData: Bool?,
        reason: String?,
        expires: Int?
    ) {
        self.body = .init(
            communityId: communityId,
            personId: personId,
            ban: ban,
            removeData: removeData,
            reason: reason,
            expires: expires
        )
    }
}
