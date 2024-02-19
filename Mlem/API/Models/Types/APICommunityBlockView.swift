//
//  APICommunityBlockView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommunityBlockView.ts
struct APICommunityBlockView: Codable {
    let person: APIPerson
    let community: APICommunity

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
