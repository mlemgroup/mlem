//
//  PersonProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Foundation

public struct PersonProperties: UnifiedPropertiesProviding {
    let actorId: ActorIdentifier
    let id: Int
    let name: String
    let created: Date
    let instanceId: Int
    var displayName: String
    var avatar: URL?
    var banner: URL?
    var note: String?
    var updated: Date?
    var description: String?
    var matrixUserId: String?
    var isBot: Bool
    var instanceBan: InstanceBanType
    var deleted: Bool
    
    var isAdmin: Bool?
    var postCount: Int?
    var commentCount: Int?
    var site: (any Instance)?
    var moderatedCommunities: [any Community]?
    
    @MainActor
    public init(api: ApiClient, snapshot: AnyCommentSnapshot) {
        // TODO: NOW
    }
    
    public mutating func merge(_ other: PersonProperties) {
        // TODO: NOW
    }
}
