//
//  UserTier1.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import Observation

@Observable
public final class Person1: Person1Providing {
    public static let tierNumber: Int = 1
    public var api: ApiClient
    public var person1: Person1 { self }
    
    public let actorId: ActorIdentifier
    public let id: Int
    
    public let name: String
    public let created: Date
    public let instanceId: Int
    
    public var updated: Date? = .distantPast
    public var displayName: String
    public var description: String?
    public var matrixId: String?
    public var avatar: URL?
    public var banner: URL?
    
    public var deleted: Bool = false
    public var isBot: Bool = false
    
    public var purged: Bool = false
    
    public var instanceBan: InstanceBanType = .notBanned
    
    // This isn't included in the ApiPerson, and so is set externally by Post2 instead
    var blockedManager: StateManager<Bool>
    public var blocked: Bool { blockedManager.displayedValue }
    
    // Communities from which this person is *known* to be banned.
    // If an ID is not in this set, its status is unknown.
    //
    // Don't make this public. Instead, use the `bannedFromCommunity` property of
    // Post2/Comment2/Reply2. Accessing it from there guarantees that the ban
    // status is known. Those properties access this set as a shared source-of-truth.
    var knownCommunityBanStates: [Int: Bool] = .init()
    
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
        matrixId: String?,
        avatar: URL?,
        banner: URL?,
        deleted: Bool,
        isBot: Bool,
        instanceBan: InstanceBanType,
        blocked: Bool?
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
        self.matrixId = matrixId
        self.avatar = avatar
        self.banner = banner
        self.deleted = deleted
        self.isBot = isBot
        self.instanceBan = instanceBan
        self.blockedManager = .init(wrappedValue: blocked ?? api.blocks?.people.keys.contains(actorId) ?? false)
        blockedManager.onSet = { newValue, type, _ in
            if type != .receive {
                if newValue {
                    api.blocks?.people[actorId] = id
                } else {
                    api.blocks?.people.removeValue(forKey: actorId)
                }
            }
        }
    }
    
    func updateKnownCommunityBanState(id: Int, banned: Bool) {
        if banned {
            // This `if` statement avoids unneccessary state update
            if !(knownCommunityBanStates[id] ?? false) {
                knownCommunityBanStates[id] = true
            }
        } else {
            if knownCommunityBanStates[id] ?? true {
                knownCommunityBanStates[id] = false
            }
        }
    }
}
