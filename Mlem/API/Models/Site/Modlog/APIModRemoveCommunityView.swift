//
//  APIModRemoveCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModRemoveCommunityView.ts
struct APIModRemoveCommunityView: Decodable {
    let modRemoveCommunity: APIModRemoveCommunity
    let moderator: APIPerson?
    let community: APICommunity
}
