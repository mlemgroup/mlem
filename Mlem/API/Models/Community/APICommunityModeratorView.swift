//
//  APICommunityModeratorView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views_actor::structs::CommunityModeratorView
struct APICommunityModeratorView: Decodable {
    internal init(
        community: APICommunity = .mock,
        moderator: APIPerson = .mock
    ) {
        self.community = community
        self.moderator = moderator
    }
    
    let community: APICommunity
    let moderator: APIPerson
}

extension APICommunityModeratorView: Mockable {
    static var mock: APICommunityModeratorView = .init()
}

extension APICommunityModeratorView: Identifiable {
    var id: String { "\(moderator.id)-\(community.id)" }
}
