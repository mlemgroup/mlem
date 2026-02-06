//
//  ApiRepository+Inbox.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

extension ApiRepository {
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2Snapshot] {
        try await performingForConnection { connection in
            try await connection.getMessages(
                creatorId: creatorId,
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
    }

    func getReplyNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        try await performingForConnection { connection in
            try await connection.getReplyNotifications(
                page: page,
                cursor: cursor,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
    }
    
    func getMentionNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        try await performingForConnection { connection in
            try await connection.getMentionNotifications(
                page: page,
                cursor: cursor,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
    }

    func getMessageNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        try await performingForConnection { connection in
            try await connection.getMessageNotifications(
                page: page,
                cursor: cursor,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
    }
    
    func markNotificationAsRead(
        type: InboxNotificationContentType,
        id: Int,
        contentId: Int,
        read: Bool
    ) async throws {
        try await performingForConnection { connection in
            try await connection.markNotificationAsRead(
                type: type,
                id: id,
                contentId: contentId,
                read: read
            )
        }
    }

    func markAllAsRead() async throws {
        try await performingForConnection { connection in
            try await connection.markAllAsRead()
        }
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        try await performingForConnection { connection in
            try await connection.getPersonalUnreadCount()
        }
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2Snapshot {
        try await performingForConnection { connection in
            try await connection.createMessage(personId: personId, content: content)
        }
    }
    
    func editMessage(id: Int, content: String) async throws -> Message2Snapshot {
        try await performingForConnection { connection in
            try await connection.editMessage(id: id, content: content)
        }
    }
    
    func reportMessage(id: Int, reason: String) async throws -> ReportSnapshot {
        try await performingForConnection { connection in
            try await connection.reportMessage(id: id, reason: reason)
        }
    }
    
    func deleteMessage(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Message2Snapshot {
        try await performingForConnection { connection in
            try await connection.deleteMessage(id: id, delete: delete)
        }
    }
}
