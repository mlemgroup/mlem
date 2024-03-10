//
//  APIModTransferCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModTransferCommunityView.ts
struct APIModTransferCommunityView: Decodable {
    let modTransferCommunity: APIModTransferCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let moddedPerson: APIPerson
}
