//
//  APIModBanFromCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModBanFromCommunityView.ts
struct APIModBanFromCommunityView: Codable {
    let mod_ban_from_community: APIModBanFromCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let banned_person: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
