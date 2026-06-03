//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension PieFedConnection {
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2Snapshot] {
        if let creatorId {
            if unreadOnly {
                throw ApiClientError.featureUnsupported
            }
            let request = PieFedGetPrivateMessagesConversationRequest(
                page: page,
                limit: limit,
                personId: creatorId,
                conversationId: nil
            )
            let response = try await perform(request)
            return try response.privateMessages.map { try .init(from: $0) }
        } else {
            let request = PieFedListPrivateMessagesRequest(
                unreadOnly: unreadOnly,
                page: page,
                limit: limit
            )
            let response = try await perform(request)
            return try response.privateMessages.map { try .init(from: $0) }
        }
    }
    
    func getReplyNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        let request = PieFedGetRepliesRequest(
            sort: .new,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        let response = try await perform(request)
        return try (notifications: response.replies.map { try .init(from: $0, isMention: false) }, cursor: nil)
    }

    func getMentionNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        let request = PieFedGetMentionsRequest(
            sort: .new,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        let response = try await perform(request)
        return try (notifications: response.replies.map { try .init(from: $0, isMention: true) }, cursor: nil)
    }

    func getMessageNotifications(
        page: Int?,
        cursor: String?,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> (notifications: [InboxNotificationSnapshot], cursor: String?) {
        let request = PieFedListPrivateMessagesRequest(
            unreadOnly: unreadOnly,
            page: page,
            limit: limit
        )
        let response = try await perform(request)
        return try (notifications: response.privateMessages.map { try .init(from: $0) }, cursor: nil)
    }
    
    func markNotificationAsRead(
        type: InboxNotificationContentType,
        id: Int,
        contentId: Int,
        read: Bool
    ) async throws {
        switch type {
        case .reply:
            try await self.markReplyAsRead(id: contentId, read: read)
        case .mention:
            try await self.markMentionAsRead(id: contentId, read: read)
        case .message:
            try await self.markMessageAsRead(id: contentId, read: read)
        }
    }

    private func markReplyAsRead(id: Int, read: Bool = true) async throws {
        let request = PieFedMarkReplyAsReadRequest(commentReplyId: id, read: read)
        try await perform(request)
    }
    
    private func markMentionAsRead(id: Int, read: Bool = true) async throws {
        let request = PieFedMarkReplyAsReadRequest(commentReplyId: id, read: read)
        try await perform(request)
    }
    
    private func markMessageAsRead(id: Int, read: Bool = true) async throws {
        let request = PieFedMarkPrivateMessageAsReadRequest(privateMessageId: id, read: read)
        try await perform(request)
    }
    
    func markAllAsRead() async throws {
        let request = PieFedMarkAllRepliesReadRequest()
        try await perform(request)
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        let request = PieFedGetUnreadCountRequest()
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2Snapshot {
        let request = PieFedCreatePrivateMessageRequest(content: content, recipientId: personId)
        let response = try await perform(request)
        return try .init(from: response.privateMessageView)
    }
    
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2Snapshot {
        let request = PieFedEditPrivateMessageRequest(privateMessageId: id, content: content)
        let response = try await perform(request)
        return try .init(from: response.privateMessageView)
    }
    
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> ReportSnapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func deleteMessage(id: Int, delete: Bool) async throws -> Message2Snapshot {
        let request = PieFedDeletePrivateMessageRequest(
            messageId: id,
            deleted: delete,
            privateMessageId: id
        )
        let response = try await perform(request)
        return try .init(from: response.privateMessageView)
    }
}
