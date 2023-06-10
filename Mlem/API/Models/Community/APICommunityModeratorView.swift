//
//  APICommunityModeratorView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APICommunityModeratorView: Decodable {
    let community: APICommunity
    let moderator: APIPerson
}

extension APICommunityModeratorView: Identifiable {
    var id: Int { moderator.id }
}
