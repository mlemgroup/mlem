//
//  ApiAdminPurgeCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgeCommunityView.ts
struct ApiAdminPurgeCommunityView: Decodable {
    let adminPurgeCommunity: ApiAdminPurgeCommunity
    let admin: APIPerson?
}
