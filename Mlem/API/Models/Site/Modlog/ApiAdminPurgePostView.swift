//
//  ApiAdminPurgePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgePostView.ts
struct ApiAdminPurgePostView: Decodable {
    let adminPurgePost: ApiAdminPurgePost
    let admin: APIPerson?
    let community: APICommunity
}
