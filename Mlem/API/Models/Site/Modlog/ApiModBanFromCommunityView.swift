//
//  ApiModBanFromCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModBanFromCommunityView.ts
struct ApiModBanFromCommunityView: Decodable {
    let mod_ban_from_community: ApiModBanFromCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let banned_person: APIPerson
}
