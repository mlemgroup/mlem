//
//  Person.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Observation
import Foundation

@Observable
public class Person:
    UnifiedModelProviding,
    Blockable {
//    ContentIdentifiable,
//    SelectableContentProviding,
//    PurgableProviding,
//    Sharable,
//    FeedLoadable where FilterType == PersonFilterType {
    public typealias Properties = PersonProperties
    
    public var api: ApiClient
    private let properties: PersonProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Person> = .init(parent: self, properties: properties)
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
    public var blocked: Bool
    
    // Communities from which this person is *known* to be banned.
    // If an ID is not in this set, its status is unknown.
    //
    // Don't make this public. Instead, use the `bannedFromCommunity` property of
    // Post2/Comment2/Reply2. Accessing it from there guarantees that the ban
    // status is known. Those properties access this set as a shared source-of-truth.
    var knownCommunityBanStates: [Int: Bool] = .init()
    
    // MARK: API Properties
    // Properties that are provided by the API
    
    public let actorId: ActorIdentifier
    public let id: Int
    public let name: String
    public let created: Date
    public let instanceId: Int
    public var displayName: String
    public var avatar: URL?
    public var banner: URL?
    public var note: String?
    public var updated: Date?
    public var description: String?
    public var matrixUserId: String?
    public var isBot: Bool
    public var instanceBan: InstanceBanType
    public var deleted: Bool
    
    public var isAdmin: ExpectedValue<Bool>
    public var postCount: ExpectedValue<Int>
    public var commentCount: ExpectedValue<Int>
    public var instance: ExpectedValue<(any Instance)>
    public var moderatedCommunities: ExpectedValue<[any Community]>
    
    public init(api: ApiClient, properties: PersonProperties) {
        self.api = api
        self.properties = properties
        self.blocked = api.blocks?.people.keys.contains(properties.actorId) ?? false
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.name = properties.name
        self.created = properties.created
        self.instanceId = properties.instanceId
        self.displayName = properties.displayName
        self.avatar = properties.avatar
        self.banner = properties.banner
        self.note = properties.note
        self.updated = properties.updated
        self.description = properties.description
        self.matrixUserId = properties.matrixUserId
        self.isBot = properties.isBot
        self.instanceBan = properties.instanceBan
        self.deleted = properties.deleted
        
        // because upgrade() is not available until all properties are initialized, first populate all properties
        // with ExpectedValues that don't actually do anything, then reassign them properly at the end of the init
        // this is somewhat cumbersome but avoids lazy vars, which are very awkward in Observables
        self.isAdmin = dummyExpectedValue(properties.isAdmin)
        self.postCount = dummyExpectedValue(properties.postCount)
        self.commentCount = dummyExpectedValue(properties.commentCount)
        self.instance = dummyExpectedValue(properties.instance)
        self.moderatedCommunities = dummyExpectedValue(properties.moderatedCommunities)
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() })
        }
        self.isAdmin = expectedValue(properties.isAdmin)
        self.postCount = expectedValue(properties.postCount)
        self.commentCount = expectedValue(properties.commentCount)
        self.instance = expectedValue(properties.instance)
        self.moderatedCommunities = expectedValue(properties.moderatedCommunities)
    }
    
    public func update(with properties: PersonProperties) {
        setIfChanged(\.displayName, properties.displayName)
        setIfChanged(\.avatar, properties.avatar)
        setIfChanged(\.banner, properties.banner)
        setIfChanged(\.note, properties.note)
        setIfChanged(\.updated, properties.updated)
        setIfChanged(\.description, properties.description)
        setIfChanged(\.matrixUserId, properties.matrixUserId)
        setIfChanged(\.isBot, properties.isBot)
        setIfChanged(\.instanceBan, properties.instanceBan)
        setIfChanged(\.deleted, properties.deleted)
        
        setIfChanged(\.isAdmin.value_, properties.isAdmin)
        setIfChanged(\.postCount.value_, properties.postCount)
        setIfChanged(\.commentCount.value_, properties.commentCount)
        
        setIfNil(\.instance.value_, properties.instance)
        // TODO: NOW
        // setIfChanged(\.moderatedCommunities.value_, properties.moderatedCommunities)
    }
    
    public func softUpdate(with properties: PersonProperties) {
        setIfNil(\.isAdmin.value_, properties.isAdmin)
        setIfNil(\.postCount.value_, properties.postCount)
        setIfNil(\.commentCount.value_, properties.commentCount)
        
        setIfNil(\.instance.value_, properties.instance)
        setIfNil(\.moderatedCommunities.value_, properties.moderatedCommunities)
    }
    
    // MARK: Upgrades
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func fetchUpgraded() async throws -> PersonProperties {
        let snapshot = try await api.repository.getPerson(id: id)
        return await .init(api: api, snapshot: .person3(snapshot))
    }
    
    // MARK: Logic
    
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

// MARK: - Computed

// MARK: - Interactions

public extension Person {
    
}
