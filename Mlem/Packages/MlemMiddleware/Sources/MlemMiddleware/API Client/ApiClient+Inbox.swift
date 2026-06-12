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

    func getReplyNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotification], cursor: String?) {
        try await inboxLock.withLock {
            guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
            let response = try await repository.getReplyNotifications(
                page: page,
                cursor: cursor,
                limit: limit,
                unreadOnly: unreadOnly
            )
            return await (
                notifications: caches.notification.getModels(api: self, from: response.notifications, myPersonId: myPersonId),
                cursor: response.cursor
            )
        }
    }
    
    func getMentionNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotification], cursor: String?) {
        try await inboxLock.withLock {
            guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
            let response = try await repository.getMentionNotifications(
                page: page,
                cursor: cursor,
                limit: limit,
                unreadOnly: unreadOnly
            )
            return await (
                notifications: caches.notification.getModels(api: self, from: response.notifications, myPersonId: myPersonId),
                cursor: response.cursor
            )
        }
    }

    func getMessageNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotification], cursor: String?) {
        try await inboxLock.withLock {
            guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
            let response = try await repository.getMessageNotifications(
                page: page,
                cursor: cursor,
                limit: limit,
                unreadOnly: unreadOnly
            )
            return await (
                notifications: caches.notification.getModels(api: self, from: response.notifications, myPersonId: myPersonId),
                cursor: response.cursor
            )
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
