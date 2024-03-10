//
//  APIAdminPurgePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgePostView.ts
struct APIAdminPurgePostView: Decodable {
    let adminPurgePost: APIAdminPurgePost
    let admin: APIPerson?
    let community: APICommunity
}
