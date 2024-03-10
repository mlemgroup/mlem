//
//  APIModAddCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModAddCommunityView.ts
struct APIModAddCommunityView: Decodable {
    let modAddCommunity: APIModAddCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let moddedPerson: APIPerson
}
