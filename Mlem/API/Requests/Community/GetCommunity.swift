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
        account: SavedAccount,
        communityId: Int
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "id", value: "\(communityId)")
        ]
    }

    init(
        account: SavedAccount,
        name: String
    ) {
        self.instanceURL = account.instanceLink
        self.queryItems = [
            .init(name: "auth", value: account.accessToken),
            .init(name: "name", value: name)
        ]
    }
}

// lemmy_api_common::community::GetCommunityResponse
struct GetCommunityResponse: Decodable {
    var communityView: APICommunityView
    // only appears if it is remote
    let site: APISite?
    let moderators: [APICommunityModeratorView]
    let online: Int
    let discussionLanguages: [Int]
    let defaultPostLanguage: Int?
}
