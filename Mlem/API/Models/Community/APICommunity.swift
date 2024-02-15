//
//  APICommunity.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::community::CommunitySafe
struct APICommunity: Codable, Identifiable, ActorIdentifiable {
    internal init(
        id: Int = 0,
        name: String = "Mock Community",
        title: String = "Mock",
        description: String? = nil,
        published: Date = .mock,
        updated: Date? = nil,
        removed: Bool = false,
        deleted: Bool = false,
        nsfw: Bool = false,
        actorId: URL = .mock,
        local: Bool = false,
        icon: String? = nil,
        banner: String? = nil,
        hidden: Bool = false,
        postingRestrictedToMods: Bool = false,
        instanceId: Int = 0
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.description = description
        self.published = published
        self.updated = updated
        self.removed = removed
        self.deleted = deleted
        self.nsfw = nsfw
        self.actorId = actorId
        self.local = local
        self.icon = icon
        self.banner = banner
        self.hidden = hidden
        self.postingRestrictedToMods = postingRestrictedToMods
        self.instanceId = instanceId
    }
    
    let id: Int
    let name: String
    let title: String
    let description: String?
    let published: Date
    let updated: Date?
    let removed: Bool
    let deleted: Bool
    let nsfw: Bool
    let actorId: URL
    let local: Bool
    let icon: String?
    let banner: String?
    let hidden: Bool
    let postingRestrictedToMods: Bool
    let instanceId: Int
}

extension APICommunity: Mockable {
    static var mock: APICommunity = .init()
}

extension APICommunity: Equatable, Hashable {
    static func == (lhs: APICommunity, rhs: APICommunity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension APICommunity: Comparable {
    static func < (lhs: APICommunity, rhs: APICommunity) -> Bool {
        let lhsFullCommunity = lhs.name + (lhs.actorId.host ?? "")
        let rhsFullCommunity = rhs.name + (rhs.actorId.host ?? "")
        return lhsFullCommunity < rhsFullCommunity
    }
}

extension APICommunity {
    var iconUrl: URL? { LemmyURL(string: icon)?.url }
    var bannerUrl: URL? { LemmyURL(string: banner)?.url }
}
