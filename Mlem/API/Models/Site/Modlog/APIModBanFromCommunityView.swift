//
//  APIModBanFromCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModBanFromCommunityView.ts
struct APIModBanFromCommunityView: Decodable {
    let modBanFromCommunity: APIModBanFromCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let bannedPerson: APIPerson
}
