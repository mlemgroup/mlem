//
//  APIModHideCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModHideCommunityView.ts
struct APIModHideCommunityView: Decodable {
    let modHideCommunity: APIModHideCommunity
    let admin: APIPerson?
    let community: APICommunity
}
