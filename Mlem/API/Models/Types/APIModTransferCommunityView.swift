//
//  APIModTransferCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModTransferCommunityView.ts
struct APIModTransferCommunityView: Codable {
    let mod_transfer_community: APIModTransferCommunity
    let moderator: APIPerson?
    let community: APICommunity
    let modded_person: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        return [

        ]
    }

}
