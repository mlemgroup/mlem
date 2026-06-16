//
//  Message.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-06-15.
//

import Observation
import Foundation

public class Message: UnifiedModelProviding {
    public typealias Properties = MessageProperties
    
    public var api: ApiClient
    private let properties: Properties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Message> = .init(parent: self, properties: properties)
    
    // MARK: API Properties
    // Properties that are provided by the API
    
    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let recipientId: Int
    public let created: Date
    public var content: String
    public var updated: Date?
    public var read: Bool
    public var deleted: Bool
    
    public var creator: ExpectedValue<Person>
    public var recipient: ExpectedValue<Person>
    
    public init(api: ApiClient, properties: MessageProperties) {
        self.api = api
        self.properties = properties
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.creatorId = properties.creatorId
        self.recipientId = properties.recipientId
        self.created = properties.created
        self.content = properties.content
        self.updated = properties.updated
        self.read = properties.read
        self.deleted = properties.deleted
        
        self.creator = dummyExpectedValue(properties.creator)
        self.recipient = dummyExpectedValue(properties.recipient)
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() })
        }
        self.creator = expectedValue(properties.creator)
        self.recipient = expectedValue(properties.recipient)
    }
    
    public func update(with properties: MessageProperties) {
        setIfChanged(\.content, properties.content)
        setIfChanged(\.updated, properties.updated)
        setIfChanged(\.read, properties.read)
        setIfChanged(\.deleted, properties.deleted)
        
        // creator and recipient are not expected to change, just need to be assigned if absent
        setIfNil(\.creator.value_, properties.creator)
        setIfNil(\.recipient.value_, properties.recipient)
    }
    
    public func softUpdate(with properties: MessageProperties) {
        setIfNil(\.creator.value_, properties.creator)
        setIfNil(\.recipient.value_, properties.recipient)
    }
    
    public func resolve(with api: ApiClient) async throws -> Self {
        // doesn't make sense to reload a message with a different account
        assertionFailure("Not a resolvable entity")
        throw ModelError.notResolvable
    }
    
    // MARK: Upgrades
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func fetchUpgraded() async throws -> MessageProperties {
        assertionFailure("Why was this called?")
        // The API has no way to directly fetch a message, so we have to do this.
        guard !deleted else {
            assertionFailure("Tried to upgrade a deleted message")
            throw ModelError.messageDeleted
        }
        let snapshot = try await api.repository.deleteMessage(id: id, delete: false)
        return properties
    }
}
