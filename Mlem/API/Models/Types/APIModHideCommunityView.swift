//
//  APIModHideCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModHideCommunityView.ts
struct APIModHideCommunityView: Codable {
    let mod_hide_community: APIModHideCommunity
    let admin: APIPerson?
    let community: APICommunity

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
