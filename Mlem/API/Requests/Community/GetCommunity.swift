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
    internal init(
        communityView: APICommunityView = .mock,
        site: APISite? = nil,
        moderators: [APICommunityModeratorView] = [],
        discussionLanguages: [Int] = [],
        defaultPostLanguage: Int? = nil
    ) {
        self.communityView = communityView
        self.site = site
        self.moderators = moderators
        self.discussionLanguages = discussionLanguages
        self.defaultPostLanguage = defaultPostLanguage
    }
    
    var communityView: APICommunityView
    // only appears if it is remote
    let site: APISite?
    let moderators: [APICommunityModeratorView]
    let discussionLanguages: [Int]
    let defaultPostLanguage: Int?
}

extension GetCommunityResponse: Mockable {
    static var mock: GetCommunityResponse = .init()
}

extension GetCommunityResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { communityView.community.actorId }
    var id: Int { communityView.community.id }
}
