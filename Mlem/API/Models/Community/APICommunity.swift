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
    let icon: URL?
    let banner: URL?
    let hidden: Bool
    let postingRestrictedToMods: Bool
    let instanceId: Int
}

extension APICommunity: Equatable {
    static func == (lhs: APICommunity, rhs: APICommunity) -> Bool {
        lhs.id == rhs.id
    }
}
