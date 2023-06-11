//
//  GetCommunityRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct GetCommunityRequest: APIGetRequest {
    
    typealias Response = GetCommunityResponse
    
    let instanceURL: URL
    let path = "community"
    let queryItems: [URLQueryItem]
    
    init(
        account: SavedAccount,
        communityId: Int
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "id", value: "\(communityId)")
        ]
    }
}

struct GetCommunityResponse: Decodable {
    var communityView: APICommunityView
    let moderators: [APICommunityModeratorView]
    let online: Int
}
