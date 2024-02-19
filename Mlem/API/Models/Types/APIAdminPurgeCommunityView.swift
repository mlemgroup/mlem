//
//  APIAdminPurgeCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/AdminPurgeCommunityView.ts
struct APIAdminPurgeCommunityView: Codable {
    let admin_purge_community: APIAdminPurgeCommunity
    let admin: APIPerson?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
