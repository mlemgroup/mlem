//
//  ApiModHideCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModHideCommunityView.ts
struct ApiModHideCommunityView: Decodable {
    let modHideCommunity: ApiModHideCommunity
    let admin: APIPerson?
    let community: APICommunity
}
