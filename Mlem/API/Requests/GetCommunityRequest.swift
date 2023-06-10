//
//  GetCommunityRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

struct GetCommunityRequest: APIRequest {
    
    typealias Response = GetCommunityResponse
    
    let endpoint: URL
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    
    init(
        account: SavedAccount,
        communityId: Int
    ) {
        let queryItems: [URLQueryItem] = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "id", value: "\(communityId)")
        ]
        
        self.queryItems = queryItems
        self.endpoint = account.instanceLink
            .appending(path: "community")
            .appending(queryItems: queryItems)
        self.method = .get
    }
}

struct GetCommunityResponse: Decodable {
    var communityView: APICommunityView
    let moderators: [APICommunityModeratorView]
    let online: Int
}
