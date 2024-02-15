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
        session: APISession,
        communityId: Int,
        follow: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            community_id: communityId,
            follow: follow,
            auth: session.token
        )
    }
}

// lemmy_api_common::community::CommunityResponse
struct CommunityResponse: Decodable {
    internal init(
        communityView: APICommunityView = .mock,
        discussionLanguages: [Int] = []
    ) {
        self.communityView = communityView
        self.discussionLanguages = discussionLanguages
    }
    
    let communityView: APICommunityView
    let discussionLanguages: [Int]
}

extension CommunityResponse: Mockable {
    static var mock: CommunityResponse = .init()
}
