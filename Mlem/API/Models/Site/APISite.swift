//
//  APISite.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12/06/2023.
//

import Foundation

// lemmy_db_schema::source::site::Site
struct APISite: Decodable, ActorIdentifiable, Identifiable {
    internal init(
        id: Int = 0,
        name: String = "Mock Site",
        sidebar: String? = nil,
        published: Date = .mock,
        icon: String? = nil,
        banner: String? = nil,
        description: String? = nil,
        actorId: URL = .init(string: "https://mock.site")!,
        lastRefreshedAt: Date = .mock,
        inboxUrl: String = "",
        publicKey: String = "",
        instanceId: Int = 0
    ) {
        self.id = id
        self.name = name
        self.sidebar = sidebar
        self.published = published
        self.icon = icon
        self.banner = banner
        self.description = description
        self.actorId = actorId
        self.lastRefreshedAt = lastRefreshedAt
        self.inboxUrl = inboxUrl
        self.publicKey = publicKey
        self.instanceId = instanceId
    }
    
    let id: Int
    let name: String
    let sidebar: String?
    let published: Date
    let icon: String?
    let banner: String?
    let description: String?
    let actorId: URL
    let lastRefreshedAt: Date
    let inboxUrl: String
    let publicKey: String
    let instanceId: Int
}

extension APISite: Mockable {
    static var mock: APISite = .init()
}

extension APISite {
    var iconUrl: URL? { LemmyURL(string: icon)?.url }
    var bannerUrl: URL? { LemmyURL(string: banner)?.url }
}
