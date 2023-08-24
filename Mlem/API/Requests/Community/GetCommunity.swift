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

    let instanceURL: URL
    let path = "community"
    let queryItems: [URLQueryItem]

    init(
        session: APISession,
        communityId: Int
    ) {
        self.instanceURL = session.URL
        self.queryItems = [
            .init(name: "auth", value: session.token),
            .init(name: "id", value: "\(communityId)")
        ]
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
