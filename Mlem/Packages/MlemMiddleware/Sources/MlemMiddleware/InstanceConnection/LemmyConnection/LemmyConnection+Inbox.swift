//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension LemmyConnection {
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2Snapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyGetPrivateMessageRequest(
                unreadOnly: unreadOnly,
                page: page,
                limit: limit,
                creatorId: creatorId
            )
        }
        return try response.privateMessages.map { try .init(from: $0) }
    }
    
    func getReplyNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        let response = try await performingForEndpoint { _ in
            guard let page else { throw ApiClientError.featureUnsupported }
            return LemmyListRepliesRequest(
                sort: .new,
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
        return try (notifications: response.replies.map { try .init(from: $0) }, cursor: nil)
    }

    func getMentionNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        let response = try await performingForEndpoint { _ in
            guard let page else { throw ApiClientError.featureUnsupported }
            return LemmyListMentionsRequest(
                sort: .new,
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
        return try (notifications: response.mentions.map { try .init(from: $0) }, cursor: nil)
    }

    func getMessageNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        let response = try await performingForEndpoint { endpoint in
            guard let page else { throw ApiClientError.featureUnsupported }
            return LemmyGetPrivateMessageRequest(
                unreadOnly: unreadOnly,
                page: page,
                limit: limit,
                creatorId: nil
            )
        }
        return try (notifications: response.privateMessages.map { try .init(from: $0) }, cursor: nil)
    }
    
    func markNotificationAsRead(
        type: InboxNotificationContentType,
        id: Int,
        contentId: Int,
        read: Bool = true
    ) async throws {
        try await processingForEndpoint { endpoint in
            guard endpoint == .v3 else { throw ApiClientError.featureUnsupported }
            switch type {
            case .reply:
                try await self.markReplyAsRead(id: contentId, read: read)
            case .mention:
                try await self.markMentionAsRead(id: contentId, read: read)
            case .message:
                try await self.markMessageAsRead(id: contentId, read: read)
            }
        }
    }
    
    func markAllAsRead() async throws {
        _ = try await performingForEndpoint { endpoint in
            LemmyMarkAllNotificationsReadRequest(endpoint: endpoint)
        }
    }
    
    func markReplyAsRead(id: Int, read: Bool = true) async throws {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                try await self.perform(LemmyMarkReplyAsReadRequest(commentReplyId: id, read: read), endpoint: .v3)
            case .v4:
                try await self.perform(LemmyMarkNotificationAsReadRequest(notificationId: id, read: read), endpoint: .v4)
            }
        }
    }
    
    func markMentionAsRead(id: Int, read: Bool = true) async throws {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                try await self.perform(LemmyMarkPersonMentionAsReadRequest(personMentionId: id, read: read), endpoint: .v3)
            case .v4:
                try await self.perform(LemmyMarkNotificationAsReadRequest(notificationId: id, read: read), endpoint: .v4)
            }
        }
    }
    
    func markMessageAsRead(id: Int, read: Bool = true) async throws {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                try await self.perform(LemmyMarkPmAsReadRequest(privateMessageId: id, read: read), endpoint: .v3)
            case .v4:
                try await self.perform(LemmyMarkNotificationAsReadRequest(notificationId: id, read: read), endpoint: .v4)
            }
        }
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyUnreadCountRequest()
        }
        return try .init(from: response)
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyCreatePrivateMessageRequest(
                endpoint: endpoint,
                content: content,
                recipientId: personId
            )
        }
        return try .init(from: response.privateMessageView)
    }
    
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyUpdatePrivateMessageRequest(
                endpoint: endpoint,
                privateMessageId: id,
                content: content
            )
        }
        return try .init(from: response.privateMessageView)
    }
    
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> ReportSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyCreatePmReportRequest(endpoint: endpoint, privateMessageId: id, reason: reason)
        }
        return try .init(from: response.privateMessageReportView)
    }
    
    @discardableResult
    func deleteMessage(id: Int, delete: Bool) async throws -> Message2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyDeletePrivateMessageRequest(endpoint: endpoint, privateMessageId: id, deleted: delete)
        }
        return try .init(from: response.privateMessageView)
    }
}
