//
//  MessageProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-06-15.
//

import Foundation

public struct MessageProperties: UnifiedPropertiesProviding {
    // From Message1Snapshot, guaranteed to always be present
    let actorId: ActorIdentifier
    let id: Int
    let creatorId: Int
    let recipientId: Int
    let created: Date
    var content: String
    var updated: Date?
    var read: Bool
    var deleted: Bool
    
    // From Message2Snapshot
    var creator: Person?
    var recipient: Person?

    @MainActor
    public init(api: ApiClient, snapshot: AnyMessageSnapshot, myPersonId: Int) {
        let snapshot1: Message1Snapshot
        let snapshot2: Message2Snapshot?
        switch snapshot {
        case let .message1(message1Snapshot):
            snapshot1 = message1Snapshot
            snapshot2 = nil
        case let .message2(message2Snapshot):
            snapshot1 = message2Snapshot.message
            snapshot2 = message2Snapshot
        }

        actorId = snapshot1.actorId
        id = snapshot1.id
        creatorId = snapshot1.creatorId
        recipientId = snapshot1.recipientId
        created = snapshot1.created
        content = snapshot1.content
        updated = snapshot1.updated
        read = snapshot1.read
        deleted = snapshot1.deleted

        if let snapshot2 {
            creator = api.caches.person.getModel(api: api, from: .person1(snapshot2.creator))
            recipient = api.caches.person.getModel(api: api, from: .person1(snapshot2.recipient))
        }
    }
    
    public mutating func merge(_ other: MessageProperties) {
        // tier 1 properties: simple assignment
        self.content = other.content
        self.updated = other.updated
        self.read = other.read
        self.deleted = other.deleted

        // tier 2 properties: only assign if incoming non-nil
        creator = other.creator ?? self.creator
        recipient = other.recipient ?? self.recipient
    }
}
