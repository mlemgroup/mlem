//
//  APIModRemoveCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModRemoveCommunityView.ts
struct APIModRemoveCommunityView: Codable {
    let mod_remove_community: APIModRemoveCommunity
    let moderator: APIPerson?
    let community: APICommunity
}
