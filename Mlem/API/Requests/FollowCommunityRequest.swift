//
//  FollowCommunityRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 08/06/2023.
//

import Foundation

struct FollowCommunityRequest: APIRequest {
    
    typealias Response = FollowCommunityResponse
    
    let endpoint: URL
    let method: HTTPMethod
    
    struct Body: Encodable {
        let auth: String
        let community_id: Int
        let follow: Bool
    }
    
    init(
        account: SavedAccount,
        communityId: Int,
        follow: Bool
    ) throws {
        do {
            let data = try JSONEncoder().encode(
                Body(
                    auth: account.accessToken,
                    community_id: communityId,
                    follow: follow
                )
            )
            self.endpoint = account.instanceLink
                .appending(path: "community")
                .appending(path: "follow")
            self.method = .post(data)
        } catch {
            throw APIRequestError.encoding
        }
    }
}

struct FollowCommunityResponse: Decodable {
    let communityView: APICommunityView
}
