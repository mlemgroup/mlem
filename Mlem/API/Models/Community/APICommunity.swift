//
//  APICommunity.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APICommunity: Codable, Identifiable {
    let actorId: URL
    let banner: URL?
    let deleted: Bool
    let description: String?
    let hidden: Bool
    let icon: URL?
    let id: Int
    let instanceId: Int
    let local: Bool
    let name: String
    let nsfw: Bool
    let postingRestrictedToMods: Bool
    let published: Date
    let removed: Bool
    let title: String
    let updated: Date?
}

extension APICommunity: Equatable {
    static func == (lhs: APICommunity, rhs: APICommunity) -> Bool {
        lhs.id == rhs.id
    }
}
