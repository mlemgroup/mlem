//
//  APIAdminPurgePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/AdminPurgePostView.ts
struct APIAdminPurgePostView: Codable {
    let admin_purge_post: APIAdminPurgePost
    let admin: APIPerson?
    let community: APICommunity
}
