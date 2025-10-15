//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension LemmyConnection {
    func getReplies(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyListRepliesRequest(
                sort: sort.v3CommentApiType,
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
        return try response.replies.map { try .init(from: $0) }
    }
    
    func getMentions(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyListMentionsRequest(
                sort: sort.v3CommentApiType,
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
        return try response.mentions.map { try .init(from: $0) }
    }
    
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
    
    func getReplyNotifications() async throws -> [InboxNotificationSnapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyListRepliesRequest(
                sort: .new,
                page: 1,
                limit: 5,
                unreadOnly: false
            )
        }
        return try response.replies.map { try .init(from: $0) }
    }

    func getMentionNotifications() async throws -> [InboxNotificationSnapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyListMentionsRequest(
                sort: .new,
                page: 1,
                limit: 5,
                unreadOnly: false
            )
        }
        return try response.mentions.map { try .init(from: $0) }
    }

    func getMessageNotifications() async throws -> [InboxNotificationSnapshot] {
        let response = try await performingForEndpoint { _ in
            LemmyGetPrivateMessageRequest(
                unreadOnly: false,
                page: 1,
                limit: 5,
                creatorId: nil
            )
        }
        return try response.privateMessages.map { try .init(from: $0) }
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
                try await self.perform(LemmyMarkReplyAsReadRequest(commentReplyId: id, read: read))
            case .v4:
                try await self.perform(LemmyMarkNotificationAsReadRequest(notificationId: id, read: read))
            }
        }
    }
    
    func markMentionAsRead(id: Int, read: Bool = true) async throws {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                try await self.perform(LemmyMarkPersonMentionAsReadRequest(personMentionId: id, read: read))
            case .v4:
                try await self.perform(LemmyMarkNotificationAsReadRequest(notificationId: id, read: read))
            }
        }
    }
    
    func markMessageAsRead(id: Int, read: Bool = true) async throws {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                try await self.perform(LemmyMarkPmAsReadRequest(privateMessageId: id, read: read))
            case .v4:
                try await self.perform(LemmyMarkNotificationAsReadRequest(notificationId: id, read: read))
            }
        }
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyUnreadCountRequest(endpoint: endpoint)
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
