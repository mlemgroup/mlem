//
//  CommunityProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-14.
//

import Foundation

public struct CommunityProperties: UnifiedPropertiesProviding {
    // From Community1Snapshot, guaranteed to always be present
    let actorId: ActorIdentifier
    let id: Int
    let name: String
    let created: Date
    let instanceId: Int
    var updated: Date?
    var displayName: String
    var description: String?
    var deleted: Bool
    var removed: Bool
    var nsfw: Bool
    var avatar: URL?
    var banner: URL?
    var hidden: Bool
    var onlyModeratorsCanPost: Bool
    
    // From Community2Snapshot
    var subscription: SubscriptionModel?
    var postCount: Int?
    var commentCount: Int?
    var activeUserCount: ActiveUserCount?
    var bannedFromCommunity: Bool??
    
    // From Community3Snapshot
    var instance: Instance??
    var moderators: [Person]?
    var discussionLanguageIds: Set<Int>?
    
    @MainActor
    public init(api: ApiClient, snapshot: AnyCommunitySnapshot) {
        let snapshot1: Community1Snapshot
        let snapshot2: Community2Snapshot?
        let snapshot3: Community3Snapshot?
        switch snapshot {
        case let .community1(snapshot):
            snapshot1 = snapshot
            snapshot2 = nil
            snapshot3 = nil
        case let .community2(snapshot):
            snapshot1 = snapshot.community
            snapshot2 = snapshot
            snapshot3 = nil
        case let .community3(snapshot):
            snapshot1 = snapshot.community.community
            snapshot2 = snapshot.community
            snapshot3 = snapshot
        }
        
        if let snapshot3 {
            if let instance1Snapshot = snapshot3.instance {
                instance = api.caches.instance.getOptionalModel(api: api, from: .instance1(instance1Snapshot))
            } else {
                instance = nil
            }
            moderators = api.caches.person.getModels(api: api, from: snapshot3.moderators.map { .person1($0) })
            discussionLanguageIds = snapshot3.discussionLanguageIds
        }
        
        if let snapshot2 {
            subscription = snapshot2.subscription
            postCount = snapshot2.postCount
            commentCount = snapshot2.commentCount
            activeUserCount = snapshot2.activeUserCount
            bannedFromCommunity = snapshot2.bannedFromCommunity
        }
        
        actorId = snapshot1.actorId
        id = snapshot1.id
        name = snapshot1.name
        created = snapshot1.created
        instanceId = snapshot1.instanceId
        updated = snapshot1.updated
        displayName = snapshot1.displayName
        description = snapshot1.description
        deleted = snapshot1.deleted
        removed = snapshot1.removed
        nsfw = snapshot1.nsfw
        avatar = snapshot1.avatar
        banner = snapshot1.banner
        hidden = snapshot1.hidden
        onlyModeratorsCanPost = snapshot1.onlyModeratorsCanPost
    }
    
    public mutating func merge(_ other: CommunityProperties) {
        // tier 1 properties: simple assignment
        self.updated = other.updated
        self.displayName = other.displayName
        self.description = other.description
        self.deleted = other.deleted
        self.removed = other.removed
        self.nsfw = other.nsfw
        self.avatar = other.avatar
        self.banner = other.banner
        self.hidden = other.hidden
        self.onlyModeratorsCanPost = other.onlyModeratorsCanPost
        
        // tier 2, 3 properties: only assign if incoming non-nil
        self.subscription = other.subscription ?? self.subscription
        self.postCount = other.postCount ?? self.postCount
        self.commentCount = other.commentCount ?? self.commentCount
        self.activeUserCount = other.activeUserCount ?? self.activeUserCount
        self.bannedFromCommunity = other.bannedFromCommunity ?? self.bannedFromCommunity
        
        self.instance = other.instance ?? self.instance
        self.moderators = other.moderators ?? self.moderators
        self.discussionLanguageIds = other.discussionLanguageIds ?? self.discussionLanguageIds
        
        let newModCount = self.moderators?.count ?? -1
    }
}
