//
//  APIModBanFromCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModBanFromCommunityView.ts
struct APIModBanFromCommunityView: Codable {
    let modBanFromCommunity: APIModBanFromCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let bannedPerson: APIPerson
}
