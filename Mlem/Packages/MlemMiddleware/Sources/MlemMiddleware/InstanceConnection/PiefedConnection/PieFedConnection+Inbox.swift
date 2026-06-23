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
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<Message2Snapshot> {
        let page = try pageInfo.cursor.requirePageNumber
        if let creatorId {
            if unreadOnly {
                throw ApiClientError.featureUnsupported
            }
            let request = PieFedGetPrivateMessagesConversationRequest(
                personId: creatorId,
                conversationId: nil,
                page: page,
                limit: pageInfo.limit
            )
            let response = try await perform(request)
            return try .fromPieFed(
                pageInfo: pageInfo,
                items: try response.privateMessages.map { try .init(from: $0) }
            )
        } else {
            let request = PieFedListPrivateMessagesRequest(
                page: page,
                limit: pageInfo.limit,
                unreadOnly: unreadOnly
            )
            let response = try await perform(request)
            return try .fromPieFed(
                pageInfo: pageInfo,
                items: try response.privateMessages.map { try .init(from: $0) }
            )
        }
    }
    
    func getReplyNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        let request = PieFedGetRepliesRequest(
            limit: pageInfo.limit,
            page: try pageInfo.cursor.requirePageNumber,
            sort: .new,
            unreadOnly: unreadOnly
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.replies.map { try .init(from: $0, isMention: false) }
        )
    }

    func getMentionNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        let request = PieFedGetMentionsRequest(
            limit: pageInfo.limit,
            page: try pageInfo.cursor.requirePageNumber,
            sort: .new,
            unreadOnly: unreadOnly
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.replies.map { try .init(from: $0, isMention: true) }
        )
    }

    func getMessageNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        let request = PieFedListPrivateMessagesRequest(
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            unreadOnly: unreadOnly
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.privateMessages.map { try .init(from: $0) }
        )
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
        let request = PieFedMarkCommentAsReadRequest(commentReplyId: id, read: read)
        try await perform(request)
    }
    
    private func markMentionAsRead(id: Int, read: Bool = true) async throws {
        let request = PieFedMarkCommentAsReadRequest(commentReplyId: id, read: read)
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
            privateMessageId: id,
            deleted: delete
        )
        let response = try await perform(request)
        return try .init(from: response.privateMessageView)
    }
}
