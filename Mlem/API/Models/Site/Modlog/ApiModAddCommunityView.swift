//
//  ApiModAddCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModAddCommunityView.ts
struct ApiModAddCommunityView: Decodable {
    let modAddCommunity: ApiModAddCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let moddedPerson: APIPerson
}
