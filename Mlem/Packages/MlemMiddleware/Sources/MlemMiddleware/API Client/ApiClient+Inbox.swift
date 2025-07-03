//
//  ApiClient+Inbox.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

public extension ApiClient {
    func getReplies(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2] {
        let snapshots = try await repository.getReplies(
            sort: sort,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        return await caches.reply2.getModels(api: self, from: snapshots)
    }
    
    func getMentions(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2] {
        let snapshots = try await repository.getMentions(
            sort: sort,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        return await caches.reply2.getModels(api: self, from: snapshots)
    }
    
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2] {
        let snapshots = try await repository.getMessages(
            creatorId: creatorId,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.message2.getModels(
            api: self,
            from: snapshots,
            myPersonId: myPersonId
        )
    }
    
    func markAllAsRead() async throws {
        try await repository.markAllAsRead()
        for reply in caches.reply1.itemCache.value.values {
            reply.content?.readManager.updateWithReceivedValue(true, semaphore: nil)
        }
        for message in caches.message1.itemCache.value.values {
            message.content?.readManager.updateWithReceivedValue(true, semaphore: nil)
        }
        unreadCount?.clear(.personal)
    }
    
    func markReplyAsRead(id: Int, read: Bool = true, semaphore: UInt? = nil) async throws {
        try await repository.markReplyAsRead(id: id, read: read)
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(false) // isMention
        let cacheId = hasher.finalize()
        if let reply = caches.reply1.retrieveModel(cacheId: cacheId) {
            reply.readManager.updateWithReceivedValue(read, semaphore: semaphore)
        }
    }
    
    func markMentionAsRead(id: Int, read: Bool = true, semaphore: UInt? = nil) async throws {
        try await repository.markMentionAsRead(id: id, read: read)
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(true) // isMention
        let cacheId = hasher.finalize()
        if let reply = caches.reply1.retrieveModel(cacheId: cacheId) {
            reply.readManager.updateWithReceivedValue(read, semaphore: semaphore)
        }
    }
    
    func markMessageAsRead(id: Int, read: Bool = true, semaphore: UInt? = nil) async throws {
        try await repository.markMessageAsRead(id: id, read: read)
        if let message = caches.message1.retrieveModel(cacheId: id) {
            message.readManager.updateWithReceivedValue(read, semaphore: semaphore)
        }
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        try await repository.getPersonalUnreadCount()
    }
    
    /// Get an ``UnreadCount`` object that continues to be updated by the ``ApiClient`` whenever an inbox item is marked read/unread.
    func getUnreadCount(alwaysMakeCalls: Bool = false) async throws -> UnreadCount {
        let unreadCount = unreadCount ?? .init(api: self)
        try await unreadCount.refresh(alwaysMakeCalls: alwaysMakeCalls)
        self.unreadCount = unreadCount
        return unreadCount
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2 {
        let snapshot = try await repository.createMessage(personId: personId, content: content)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.message2.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2 {
        let snapshot = try await repository.editMessage(id: id, content: content)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.message2.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> Report {
        let snapshot = try await repository.reportMessage(id: id, reason: reason)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func deleteMessage(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Message2 {
        let snapshot = try await repository.deleteMessage(id: id, delete: delete)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.message2.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId,
            semaphore: semaphore
        )
    }
}
