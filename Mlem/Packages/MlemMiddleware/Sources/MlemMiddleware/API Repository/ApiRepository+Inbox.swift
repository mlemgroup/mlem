//
//  ApiRepository+Inbox.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

extension ApiRepository {
    func getMessages(
        creatorId: Int? = nil,
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<Message2Snapshot> {
        try await performingForConnection { connection in
            try await connection.getMessages(
                creatorId: creatorId,
                pageInfo: pageInfo,
                unreadOnly: unreadOnly
            )
        }
    }

    func getReplyNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        try await performingForConnection { connection in
            try await connection.getReplyNotifications(
                pageInfo: pageInfo,
                unreadOnly: unreadOnly
            )
        }
    }
    
    func getMentionNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        try await performingForConnection { connection in
            try await connection.getMentionNotifications(
                pageInfo: pageInfo,
                unreadOnly: unreadOnly
            )
        }
    }

    func getMessageNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        try await performingForConnection { connection in
            try await connection.getMessageNotifications(
                pageInfo: pageInfo,
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
