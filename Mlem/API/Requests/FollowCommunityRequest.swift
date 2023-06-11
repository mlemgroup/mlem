//
//  FollowCommunityRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct FollowCommunityRequest: APIPostRequest {
    
    typealias Response = FollowCommunityResponse
    
    let instanceURL: URL
    let path = "community/follow"
    let body: Body
    
    struct Body: Encodable {
        let auth: String
        let community_id: Int
        let follow: Bool
    }
    
    init(
        account: SavedAccount,
        communityId: Int,
        follow: Bool
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            auth: account.accessToken,
            community_id: communityId,
            follow: follow
        )
    }
}

struct FollowCommunityResponse: Decodable {
    let communityView: APICommunityView
}
