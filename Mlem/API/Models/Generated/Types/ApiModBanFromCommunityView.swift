//
//  ApiModBanFromCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModBanFromCommunityView.ts
struct ApiModBanFromCommunityView: Codable {
    let modBanFromCommunity: ApiModBanFromCommunity
    let moderator: ApiPerson?
    let community: ApiCommunity
    let bannedPerson: ApiPerson
}
