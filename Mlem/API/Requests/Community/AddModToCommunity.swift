//
//  AddModToCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-17.
//

import Foundation

struct AddModToCommunityRequest: APIPostRequest {
    typealias Response = AddModToCommunityResponse

    let instanceURL: URL
    let path = "community/mod"
    let body: Body

    struct Body: Encodable {
        let community_id: Int
        let person_id: Int
        let added: Bool
        let auth: String
    }

    init(
        session: APISession,
        communityId: Int,
        personId: Int,
        added: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            community_id: communityId,
            person_id: personId,
            added: added,
            auth: session.token
        )
    }
}

struct AddModToCommunityResponse: Decodable {
    let moderators: [APICommunityModeratorView]
}
