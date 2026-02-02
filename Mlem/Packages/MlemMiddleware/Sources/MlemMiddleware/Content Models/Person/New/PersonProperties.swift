//
//  PersonProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Foundation

public struct PersonProperties: UnifiedPropertiesProviding {
    // From Person1Snapshot, guaranteed to always be present
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
    
    // From Person2Snapshot
    var isAdmin: Bool?
    var postCount: Int?
    var commentCount: Int?
    
    // From Person3Snapshot
    var instance: (any Instance)?
    var moderatedCommunities: [any Community]?
    
    @MainActor
    public init(api: ApiClient, snapshot: AnyPersonSnapshot) {
        let snapshot1: Person1Snapshot
        let snapshot2: Person2Snapshot?
        let snapshot3: Person3Snapshot?
        switch snapshot {
        case let .person1(person1Snapshot):
            snapshot1 = person1Snapshot
            snapshot2 = nil
            snapshot3 = nil
        case let .person2(person2Snapshot):
            snapshot1 = person2Snapshot.person
            snapshot2 = person2Snapshot
            snapshot3 = nil
        case let .person3(person3Snapshot):
            snapshot1 = person3Snapshot.person.person
            snapshot2 = person3Snapshot.person
            snapshot3 = person3Snapshot
        }
        
        if let snapshot3, let site = snapshot3.site {
            instance = api.caches.instance1.getModel(api: api, from: site)
            moderatedCommunities = api.caches.community1.getModels(api: api, from: snapshot3.moderatedCommunities)
        }
        
        if let snapshot2 {
            isAdmin = snapshot2.isAdmin
            postCount = snapshot2.postCount
            commentCount = snapshot2.commentCount
        }
        
        actorId = snapshot1.actorId
        id = snapshot1.id
        name = snapshot1.name
        created = snapshot1.created
        instanceId = snapshot1.instanceId
        displayName = snapshot1.displayName
        avatar = snapshot1.avatar
        banner = snapshot1.banner
        note = snapshot1.note
        updated = snapshot1.updated
        description = snapshot1.description
        matrixUserId = snapshot1.matrixUserId
        isBot = snapshot1.isBot
        instanceBan = snapshot1.instanceBan
        deleted = snapshot1.deleted
    }
    
    public mutating func merge(_ other: PersonProperties) {
        // tier 1 properties: simple assignment
        self.displayName = other.displayName
        self.avatar = other.avatar
        self.banner = other.banner
        self.note = other.note
        self.updated = other.updated
        self.description = other.description
        self.matrixUserId = other.matrixUserId
        self.isBot = other.isBot
        self.instanceBan = other.instanceBan
        self.deleted = other.deleted
        
        // tier 2, 3 properties: only assign if incoming non-nil
        isAdmin = other.isAdmin ?? self.isAdmin
        postCount = other.postCount ?? self.postCount
        commentCount = other.commentCount ?? self.commentCount
        
        instance = other.instance ?? self.instance
        moderatedCommunities = other.moderatedCommunities ?? self.moderatedCommunities
    }
}
