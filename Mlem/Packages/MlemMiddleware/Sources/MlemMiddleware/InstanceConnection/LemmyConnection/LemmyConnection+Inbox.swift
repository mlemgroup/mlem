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
            ListRepliesRequest(
                sort: sort.apiSortType,
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
            ListMentionsRequest(
                sort: sort.apiSortType,
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
            GetPrivateMessageRequest(
                unreadOnly: unreadOnly,
                page: page,
                limit: limit,
                creatorId: creatorId
            )
        }
        return try response.privateMessages.map { try .init(from: $0) }
    }
    
    func markAllAsRead() async throws {
        let response = try await performingForEndpoint { endpoint in
            MarkAllNotificationsReadRequest(endpoint: endpoint)
        }
    }
    
    func markReplyAsRead(id: Int, read: Bool = true) async throws {
        _ = try await performingForEndpoint { endpoint in
            MarkReplyAsReadRequest(endpoint: endpoint, commentReplyId: id, read: read)
        }
    }
    
    func markMentionAsRead(id: Int, read: Bool = true) async throws {
        _ = try await performingForEndpoint { _ in
            MarkPersonMentionAsReadRequest(personMentionId: id, read: read)
        }
    }
    
    func markMessageAsRead(id: Int, read: Bool = true) async throws {
        let response = try await performingForEndpoint { endpoint in
            MarkPmAsReadRequest(
                endpoint: endpoint,
                privateMessageId: id,
                read: read
            )
        }
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        let response = try await performingForEndpoint { endpoint in
            UnreadCountRequest(endpoint: endpoint)
        }
        return try .init(from: response)
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            CreatePrivateMessageRequest(
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
            UpdatePrivateMessageRequest(
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
            CreatePmReportRequest(endpoint: endpoint, privateMessageId: id, reason: reason)
        }
        return try .init(from: response.privateMessageReportView)
    }
    
    @discardableResult
    func deleteMessage(id: Int, delete: Bool) async throws -> Message2Snapshot {
        let response = try await performingForEndpoint { endpoint in
            DeletePrivateMessageRequest(endpoint: endpoint, privateMessageId: id, deleted: delete)
        }
        return try .init(from: response.privateMessageView)
    }
}
