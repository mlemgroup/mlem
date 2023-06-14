//
//  FollowCommunity.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct FollowCommunityRequest: APIPostRequest {

    typealias Response = CommunityResponse

    let instanceURL: URL
    let path = "community/follow"
    let body: Body

    // lemmy_api_common::community::FollowCommunity
    struct Body: Encodable {
        let community_id: Int
        let follow: Bool
        let auth: String
    }

    init(
        account: SavedAccount,
        communityId: Int,
        follow: Bool
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            community_id: communityId,
            follow: follow,
            auth: account.accessToken
        )
    }
}

// lemmy_api_common::community::CommunityResponse
struct CommunityResponse: Decodable {
    let communityView: APICommunityView
    let discussionLanguages: [Int]
}
