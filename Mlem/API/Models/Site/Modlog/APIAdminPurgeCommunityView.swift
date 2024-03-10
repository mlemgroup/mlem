//
//  APIAdminPurgeCommunityView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgeCommunityView.ts
struct APIAdminPurgeCommunityView: Decodable {
    let adminPurgeCommunity: APIAdminPurgeCommunity
    let admin: APIPerson?
}
