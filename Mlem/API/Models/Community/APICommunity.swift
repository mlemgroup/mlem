//
//  APICommunity.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::source::community::CommunitySafe
struct APICommunity: Codable, Identifiable {
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

extension APICommunity: APIContentType {
    var contentId: Int { id }
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
