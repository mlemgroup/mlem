//
//  ApiModRemoveCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemoveCommunityView.ts
struct ApiModRemoveCommunityView: Decodable {
    let modRemoveCommunity: ApiModRemoveCommunity
    let moderator: APIPerson?
    let community: APICommunity
}
