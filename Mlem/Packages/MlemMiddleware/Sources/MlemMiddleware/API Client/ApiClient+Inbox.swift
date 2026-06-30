//
//  ApiClient+Inbox.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

public extension ApiClient {
    func getMessages(
        creatorId: Int? = nil,
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<Message2> {
        let response = try await repository.getMessages(
            creatorId: creatorId,
            pageInfo: pageInfo,
            unreadOnly: unreadOnly
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        let messages = await caches.message2.getModels(
            api: self,
            from: response.items,
            myPersonId: myPersonId
        )
        return .init(items: messages, nextLocation: response.nextLocation)
    }

    func getReplyNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotification> {
        try await inboxLock.withLock {
            guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
            let response = try await repository.getReplyNotifications(
                pageInfo: pageInfo,
                unreadOnly: unreadOnly
            )
            let notifications = await caches.notification.getModels(api: self, from: response.items, myPersonId: myPersonId)
            return .init(items: notifications, nextLocation: response.nextLocation)
        }
    }

    func getMentionNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotification> {
        try await inboxLock.withLock {
            guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
            let response = try await repository.getMentionNotifications(
                pageInfo: pageInfo,
                unreadOnly: unreadOnly
            )
            let notifications = await caches.notification.getModels(api: self, from: response.items, myPersonId: myPersonId)
            return .init(items: notifications, nextLocation: response.nextLocation)
        }
    }

    func getMessageNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotification> {
        try await inboxLock.withLock {
            guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
            let response = try await repository.getMessageNotifications(
                pageInfo: pageInfo,
                unreadOnly: unreadOnly
            )
            let notifications = await caches.notification.getModels(api: self, from: response.items, myPersonId: myPersonId)
            return .init(items: notifications, nextLocation: response.nextLocation)
        }
    }

    func markAllAsRead() async throws {
        try await inboxLock.withLock {
            try await repository.markAllAsRead()
            _ = await Task { @MainActor in
                for notification in caches.notification.itemCache.value.values {
                    notification.content?.read = true
                }
            }.result
            unreadCount?.clear(.personal)
        }
    }
    
    /// Get an ``UnreadCount`` object that continues to be updated by the ``ApiClient`` whenever an inbox item is marked read/unread.
    func getUnreadCount() async throws -> UnreadCount {
        try await inboxLock.withLock {
            let unreadCount = unreadCount ?? .init(api: self)
            try await unreadCount.refresh()
            self.unreadCount = unreadCount
            return unreadCount
        }
    }

    @discardableResult
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
