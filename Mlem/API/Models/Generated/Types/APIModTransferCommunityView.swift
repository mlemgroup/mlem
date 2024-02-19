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
    let modTransferCommunity: APIModTransferCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let moddedPerson: APIPerson
}
