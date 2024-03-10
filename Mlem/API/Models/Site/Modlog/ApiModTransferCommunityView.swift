//
//  ApiModTransferCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModTransferCommunityView.ts
struct ApiModTransferCommunityView: Decodable {
    let modTransferCommunity: ApiModTransferCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let moddedPerson: APIPerson
}
