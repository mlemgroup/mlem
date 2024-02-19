//
//  APIModRemoveCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModRemoveCommunityView.ts
struct APIModRemoveCommunityView: Codable {
    let mod_remove_community: APIModRemoveCommunity
    let moderator: APIPerson?
    let community: APICommunity

    func toQueryItems() -> [URLQueryItem] {
        return [

        ]
    }

}
