//
//  APIModAddCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModAddCommunityView.ts
struct APIModAddCommunityView: Codable {
    let mod_add_community: APIModAddCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let modded_person: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
