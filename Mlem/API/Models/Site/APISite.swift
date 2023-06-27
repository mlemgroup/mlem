//
//  APISite.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12/06/2023.
//

import Foundation

// lemmy_db_schema::source::site::Site
struct APISite: Decodable {
    let id: Int
    let name: String
    let sidebar: String?
    let published: Date
    let icon: URL?
    let banner: URL?
    let description: String?
    let actorId: String?
    let lastRefreshedAt: Date
    let inboxUrl: String
    let publicKey: String
    let instanceId: Int
}
