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
        session: APISession,
        communityId: Int,
        hidden: Bool,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl

        self.body = try .init(
            community_id: communityId,
            hidden: hidden,
            reason: reason,
            auth: session.token
        )
    }
}
