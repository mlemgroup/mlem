//
//  PurgePostRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct PurgeCommunityRequest: APIPostRequest {
    typealias Response = SuccessResponse

    var instanceURL: URL
    let path = "admin/purge/community"
    let body: Body
    
    struct Body: Codable {
        let community_id: Int
        let reason: String?
        let auth: String
    }

    init(
        session: APISession,
        communityId: Int,
        reason: String?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            community_id: communityId,
            reason: reason,
            auth: session.token
        )
    }
}
