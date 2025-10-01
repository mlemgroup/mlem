//
//  ApiRepository+Inbox.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

extension ApiRepository {
    func getReplies(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        try await performingForConnection { connection in
            try await connection.getReplies(
                sort: sort,
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
    }
    
    func getMentions(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        try await performingForConnection { connection in
            try await connection.getMentions(
                sort: sort,
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
    }
    
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

    func getReplyNotifications() async throws -> [NotificationSnapshot] {
        try await performingForConnection { connection in
            try await connection.getReplyNotifications()
        }
    }
    
    func getMentionNotifications() async throws -> [NotificationSnapshot] {
        try await performingForConnection { connection in
            try await connection.getMentionNotifications()
        }
    }

    func getMessageNotifications() async throws -> [NotificationSnapshot] {
        try await performingForConnection { connection in
            try await connection.getMessageNotifications()
        }
    }

    func markAllAsRead() async throws {
        try await performingForConnection { connection in
            try await connection.markAllAsRead()
        }
    }
    
    func markReplyAsRead(id: Int, read: Bool = true, semaphore: UInt? = nil) async throws {
        try await performingForConnection { connection in
            try await connection.markReplyAsRead(id: id, read: read)
        }
    }
    
    func markMentionAsRead(id: Int, read: Bool = true, semaphore: UInt? = nil) async throws {
        try await performingForConnection { connection in
            try await connection.markMentionAsRead(id: id, read: read)
        }
    }
    
    func markMessageAsRead(id: Int, read: Bool = true, semaphore: UInt? = nil) async throws {
        try await performingForConnection { connection in
            try await connection.markMessageAsRead(id: id, read: read)
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
