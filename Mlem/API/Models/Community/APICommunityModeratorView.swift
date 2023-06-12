//
//  APICommunityModeratorView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_views_actor::structs::CommunityModeratorView
struct APICommunityModeratorView: Decodable {
    let community: APICommunity
    let moderator: APIPerson
}

extension APICommunityModeratorView: Identifiable {
    var id: String { "\(moderator.id)-\(community.id)" }
}
