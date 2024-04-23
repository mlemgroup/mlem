//
//  BanFromCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-15.
//

import Foundation

struct BanFromCommunityRequest: APIPostRequest {
    typealias Response = BanFromCommunityResponse

    let instanceURL: URL
    let path = "community/ban_user"
    let body: Body

    struct Body: Encodable {
        let community_id: Int
        let person_id: Int
        let ban: Bool
        let remove_data: Bool?
        let reason: String?
        let expires: Int?
        let auth: String
    }

    init(
        session: APISession,
        communityId: Int,
        personId: Int,
        ban: Bool,
        removeData: Bool?,
        reason: String?,
        expires: Int?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            community_id: communityId,
            person_id: personId,
            ban: ban,
            remove_data: removeData,
            reason: reason,
            expires: expires,
            auth: session.token
        )
    }
}

struct BanFromCommunityResponse: Decodable {
    let personView: APIPersonView
    let banned: Bool
}
