//
//  HideCommunity.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12.06.2023.
//

import Foundation

struct HideCommunityRequest: APIPutRequest {

    typealias Response = CommunityResponse

    let instanceURL: URL
    let path = "community/hide"
    let body: Body

    // lemmy_api_common::community::HideCommunity
    struct Body: Encodable {
        let community_id: Int

        let hidden: Bool
        let reason: String?

        let auth: String
    }

    init(
        account: SavedAccount,

        communityId: Int,
        hidden: Bool,
        reason: String?
    ) {
        self.instanceURL = account.instanceLink

        self.body = .init(
            community_id: communityId,
            hidden: hidden,
            reason: reason,

            auth: account.accessToken
        )
    }
}
