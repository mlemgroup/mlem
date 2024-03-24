//
//  RemoveCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct RemoveCommunityRequest: APIPostRequest {
    typealias Response = CommunityResponse
    
    struct Body: Codable {
        let community_id: Int
        let removed: Bool
        let reason: String?
        let auth: String
    }

    let instanceURL: URL
    let path = "community/remove"
    let body: Body

    init(
        session: APISession,
        communityId: Int,
        removed: Bool,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = .init(
          community_id: communityId,
          removed: removed,
          reason: reason,
          auth: try session.token
        )
    }
}
