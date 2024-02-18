//
//  ModerateCommunityLink.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-12.
//

import Foundation

struct ModerateCommunityLink: DestinationValue {
    let communityModel: CommunityModel

    func hash(into hasher: inout Hasher) {
        hasher.combine(communityModel.id)
    }
}
