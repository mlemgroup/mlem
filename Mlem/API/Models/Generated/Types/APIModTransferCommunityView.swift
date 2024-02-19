//
//  APIModTransferCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModTransferCommunityView.ts
struct APIModTransferCommunityView: Codable {
    let mod_transfer_community: APIModTransferCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let modded_person: APIPerson
}
