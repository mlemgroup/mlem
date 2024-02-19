//
//  APIAdminPurgePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/AdminPurgePostView.ts
struct APIAdminPurgePostView: Codable {
    let admin_purge_post: APIAdminPurgePost
    let admin: APIPerson?
    let community: APICommunity

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
