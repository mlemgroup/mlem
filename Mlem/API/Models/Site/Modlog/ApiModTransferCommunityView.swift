//
//  ApiModTransferCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModTransferCommunityView.ts
struct ApiModTransferCommunityView: Decodable {
    let mod_transfer_community: ApiModTransferCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let modded_person: APIPerson
}
