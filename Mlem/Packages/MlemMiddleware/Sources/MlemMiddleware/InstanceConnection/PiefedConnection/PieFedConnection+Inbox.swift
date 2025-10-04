//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension PieFedConnection {
    func getReplies(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        guard let sort = sort.piefedSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetRepliesRequest(
            sort: sort,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        let response = try await perform(request)
        return try response.replies.map { try .init(from: $0, isMention: false) }
    }
    
    func getMentions(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        guard let sort = sort.piefedSortType else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetMentionsRequest(
            sort: sort,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        let response = try await perform(request)
        return try response.replies.map { try .init(from: $0, isMention: true) }
    }
    
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
                personId: creatorId
            )
            let response = try await perform(request)
            return try response.privateMessages.map { try .init(from: $0) }
        } else {
            let request = PieFedListPrivateMessagesRequest(
                unreadOnly: unreadOnly,
                page: page,
                limit: limit,
                creatorId: nil
            )
            let response = try await perform(request)
            return try response.privateMessages.map { try .init(from: $0) }
        }
    }
    
    func getReplyNotifications() async throws -> [InboxNotificationSnapshot] {
        throw ApiClientError.featureUnsupported
    }

    func getMentionNotifications() async throws -> [InboxNotificationSnapshot] {
        throw ApiClientError.featureUnsupported
    }

    func getMessageNotifications() async throws -> [InboxNotificationSnapshot] {
        throw ApiClientError.featureUnsupported
    }

    func markAllAsRead() async throws {
        let request = PieFedMarkAllRepliesReadRequest()
        try await perform(request)
    }
    
    func markReplyAsRead(id: Int, read: Bool = true) async throws {
        let request = PieFedMarkReplyAsReadRequest(commentReplyId: id, read: read)
        try await perform(request)
    }
    
    func markMentionAsRead(id: Int, read: Bool = true) async throws {
        let request = PieFedMarkReplyAsReadRequest(commentReplyId: id, read: read)
        try await perform(request)
    }
    
    func markMessageAsRead(id: Int, read: Bool = true) async throws {
        let request = PieFedMarkPrivateMessageAsReadRequest(privateMessageId: id, read: read)
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
