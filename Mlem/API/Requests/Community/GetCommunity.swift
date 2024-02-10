//
//  GetCommunity.swift
//  Mlem
//
//  Created by Nicholas Lawson on 07/06/2023.
//

import Foundation

// lemmy_api_common::community::GetCommunity
struct GetCommunityRequest: APIGetRequest {
    typealias Response = GetCommunityResponse

    let path = "community"
    let queryItems: [URLQueryItem]

    init(communityId: Int) {
        var queryItems: [URLQueryItem] = [
            .init(name: "id", value: "\(communityId)")
        ]
        self.queryItems = queryItems
    }
}

// lemmy_api_common::community::GetCommunityResponse
struct GetCommunityResponse: Decodable {
    var communityView: APICommunityView
    // only appears if it is remote
    let site: APISite?
    let moderators: [APICommunityModeratorView]
    let discussionLanguages: [Int]
    let defaultPostLanguage: Int?
}

extension GetCommunityResponse: ActorIdentifiable {
    var actorId: URL { communityView.community.actorId }
}

