//
//  APISite.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/Site.ts
struct APISite: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let name: String
    let sidebar: String?
    let published: Date
    let updated: Date?
    let icon: URL?
    let banner: URL?
    let description: String?
    let actorId: URL
    let lastRefreshedAt: Date
    let inboxUrl: String
    let privateKey: String?
    let publicKey: String
    let instanceId: Int
}
