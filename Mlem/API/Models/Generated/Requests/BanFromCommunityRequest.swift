//
//  BanFromCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
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
            community_id: communityId,
            person_id: personId,
            ban: ban,
            remove_data: removeData,
            reason: reason,
            expires: expires
        )
    }
}
