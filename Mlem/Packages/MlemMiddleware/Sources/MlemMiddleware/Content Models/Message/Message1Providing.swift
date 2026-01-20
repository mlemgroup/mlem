//
//  Message1Providing.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public protocol Message1Providing:
    ContentModel,
    ActorIdentifiable,
    ContentIdentifiable,
    DeletableProviding,
    ReportableProviding,
    SelectableContentProviding {
    var message1: Message1 { get }
    
    var id: Int { get }
    var creatorId: Int { get }
    var recipientId: Int { get }
    var content: String { get }
    var deleted: Bool { get }
    var created: Date { get }
    var updated: Date? { get }
    
    var id_: Int? { get }
    var creatorId_: Int? { get }
    var recipientId_: Int? { get }
    var content_: String? { get }
    var deleted_: Bool? { get }
    var created_: Date? { get }
    var updated_: Date? { get }
    
    // From Message2Providing
    var creator_: Person1? { get }
    var recipient_: Person1? { get }
}

public typealias Message = Message1Providing

// SelectableContentProviding conformance
public extension Message1Providing {
    var selectableContent: String? { content }
}

public extension Message1Providing {
    static var modelTypeId: ContentType { .message }
    
    var actorId: ActorIdentifier { message1.actorId }
    var id: Int { message1.id }
    var creatorId: Int { message1.creatorId }
    var recipientId: Int { message1.recipientId }
    var content: String { message1.content }
    var deleted: Bool { message1.deleted }
    var created: Date { message1.created }
    var updated: Date? { message1.updated }
    var isOwnMessage: Bool { message1.isOwnMessage }
    
    var id_: Int? { message1.id }
    var creatorId_: Int? { message1.creatorId }
    var recipientId_: Int? { message1.recipientId }
    var content_: String? { message1.content }
    var deleted_: Bool? { message1.deleted }
    var created_: Date? { message1.created }
    var updated_: Date? { message1.updated }
    var isOwnMessage_: Bool? { message1.isOwnMessage }
    
    var creator_: Person1? { nil }
    var recipient_: Person1? { nil }
}

// ReportableProviding conformance
public extension Message1Providing {
    func isOwnContent(myPersonId: Int) -> Bool { isOwnMessage }
}

public extension Message1Providing {
    private var deletedManager: StateManager<Bool> { message1.deletedManager }
    
    func reply(content: String) async throws -> Message2 {
        try await api.createMessage(personId: recipientId, content: content)
    }
    
    func report(reason: String) async throws {
        try await api.reportMessage(id: id, reason: reason)
    }
    
    func updateDeleted(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        // TODO: UpdateQueue queued state management
        _ = deletedManager.performRequest(expectedResult: newValue) { semaphore in
            do {
                try await self.api.deleteMessage(id: self.id, delete: newValue, semaphore: semaphore)
                callback?(.success)
            } catch {
                callback?(.failure(error))
            }
        }
    }
    
    func edit(content: String) async throws {
        try await api.editMessage(id: id, content: content)
    }
}
