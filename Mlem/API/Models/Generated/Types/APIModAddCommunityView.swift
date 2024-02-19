//
//  APIModAddCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ModAddCommunityView.ts
struct APIModAddCommunityView: Codable {
    let modAddCommunity: APIModAddCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let moddedPerson: APIPerson
}
