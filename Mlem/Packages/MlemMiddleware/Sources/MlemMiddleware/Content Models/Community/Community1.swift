//
//  CommunityTier1.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation
import Observation

@Observable
public final class Community1: Community1Providing {
    public static let tierNumber: Int = 1
    public var community1: Community1 { self }
    public var api: ApiClient

    public let actorId: ActorIdentifier
    public let id: Int
    
    public let name: String
    public let created: Date
    public let instanceId: Int
    
    public var updated: Date? = .distantPast
    public var displayName: String = ""
    public var description: String?
    public var deleted: Bool = false
    public var nsfw: Bool = false
    public var avatar: URL?
    public var banner: URL?
    public var hidden: Bool = false
    public var onlyModeratorsCanPost: Bool = false
    public var visibility: ApiCommunityVisibility?
    
    public var purged: Bool = false
    
    // This isn't included in ApiCommunity - it's included in ApiCommunityView, but defined here to maintain similarity with Person models. Person models don't have the `blocked` property defined in any of the Api types, annoyingly. Instead, certain parent models such as ApiPostView contain the value.
    var blockedManager: StateManager<Bool>
    public var blocked: Bool { blockedManager.wrappedValue }
    
    public var removedManager: StateManager<Bool>
    public var removed: Bool { removedManager.wrappedValue }
  
    init(
        api: ApiClient,
        actorId: ActorIdentifier,
        id: Int,
        name: String,
        created: Date,
        instanceId: Int,
        updated: Date?,
        displayName: String,
        description: String?,
        removed: Bool,
        deleted: Bool,
        nsfw: Bool,
        avatar: URL?,
        banner: URL?,
        hidden: Bool,
        onlyModeratorsCanPost: Bool,
        blocked: Bool?,
        visibility: ApiCommunityVisibility?
    ) {
        self.api = api
        self.actorId = actorId
        self.id = id
        self.name = name
        self.created = created
        self.instanceId = instanceId
        self.updated = updated
        self.displayName = displayName
        self.description = description
        self.removedManager = .init(wrappedValue: removed)
        self.deleted = deleted
        self.nsfw = nsfw
        self.avatar = avatar
        self.banner = banner
        self.hidden = hidden
        self.onlyModeratorsCanPost = onlyModeratorsCanPost
        self.visibility = visibility
        self.blockedManager = .init(wrappedValue: blocked ?? api.blocks?.communities.keys.contains(actorId) ?? false)
        blockedManager.onSet = { newValue, type, _ in
            if type != .receive {
                if newValue {
                    api.blocks?.communities[actorId] = id
                } else {
                    api.blocks?.communities.removeValue(forKey: actorId)
                }
            }
        }
    }
}
