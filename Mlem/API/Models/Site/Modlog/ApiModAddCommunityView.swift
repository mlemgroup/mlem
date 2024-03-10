//
//  ApiModAddCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModAddCommunityView.ts
struct ApiModAddCommunityView: Decodable {
    let mod_add_community: ApiModAddCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let modded_person: APIPerson
}
