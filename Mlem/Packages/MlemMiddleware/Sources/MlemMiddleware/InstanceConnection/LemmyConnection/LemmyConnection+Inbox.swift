//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

internal extension LemmyConnection {
    func getMessages(
        creatorId: Int? = nil,
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<Message2Snapshot> {
        let response = try await performingForEndpoint { _ in
            LemmyGetPrivateMessageRequest(
                unreadOnly: unreadOnly,
                page: try pageInfo.cursor.requirePageNumber,
                limit: pageInfo.limit,
                creatorId: creatorId
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: try response.privateMessages.map { try .init(from: $0) },
            nextCursor: nil
        )
    }
    
    func getReplyNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyListRepliesRequest(
                    sort: .new,
                    page: try pageInfo.cursor.requirePageNumber,
                    limit: pageInfo.limit,
                    unreadOnly: unreadOnly
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.replies.map { try .init(from: $0) },
                    nextCursor: nil
                )
            case .v4:
                let request = LemmyListNotificationsRequest(
                    type_: .reply,
                    unreadOnly: unreadOnly,
                    creatorId: nil,
                    pageCursor: try pageInfo.cursor.requireCursorString,
                    limit: pageInfo.limit
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try .init(from: response) {
                    try .init(from: $0)
                }
            }
        }
    }

    func getMentionNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyListMentionsRequest(
                    sort: .new,
                    page: try pageInfo.cursor.requirePageNumber,
                    limit: pageInfo.limit,
                    unreadOnly: unreadOnly
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.mentions.map { try .init(from: $0) },
                    nextCursor: nil
                )
            case .v4:
                let request = LemmyListNotificationsRequest(
                    type_: .mention,
                    unreadOnly: unreadOnly,
                    creatorId: nil,
                    pageCursor: try pageInfo.cursor.requireCursorString,
                    limit: pageInfo.limit
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try .init(from: response) {
                    try .init(from: $0)
                }
            }
        }
    }

    func getMessageNotifications(
        pageInfo: PageInfo,
        unreadOnly: Bool
    ) async throws -> PagedResponse<InboxNotificationSnapshot> {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyGetPrivateMessageRequest(
                    unreadOnly: unreadOnly,
                    page: try pageInfo.cursor.requirePageNumber,
                    limit: pageInfo.limit,
                    creatorId: nil
                )
                let response = try await self.perform(request, endpoint: .v3)
                return try .fromLemmyV3(
                    pageInfo: pageInfo,
                    items: response.privateMessages.map { try .init(from: $0) },
                    nextCursor: nil
                )
            case .v4:
                let request = LemmyListNotificationsRequest(
                    type_: .privateMessage,
                    unreadOnly: unreadOnly,
                    creatorId: nil,
                    pageCursor: try pageInfo.cursor.requireCursorString,
                    limit: pageInfo.limit
                )
                let response = try await self.perform(request, endpoint: .v4)
                return try .init(from: response) {
                    try .init(from: $0)
                }
            }
        }
    }
    
    func markNotificationAsRead(
        type: InboxNotificationContentType,
        id: Int,
        contentId: Int,
        read: Bool = true
    ) async throws {
        try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                try await self.markNotificationAsReadV3(type: type, contentId: contentId, read: read)
            case .v4:
                let request = LemmyMarkNotificationAsReadRequest(notificationId: id, read: read)
                try await self.perform(request, endpoint: .v4)
            }
        }
    }

    private func markNotificationAsReadV3(
        type: InboxNotificationContentType,
        contentId: Int,
        read: Bool
    ) async throws {
        switch type {
        case .reply:
            try await self.perform(LemmyMarkReplyAsReadRequest(commentReplyId: contentId, read: read), endpoint: .v3)
        case .mention:
            try await self.perform(LemmyMarkPersonMentionAsReadRequest(personMentionId: contentId, read: read), endpoint: .v3)
        case .message:
            try await self.perform(LemmyMarkPmAsReadRequest(privateMessageId: contentId, read: read), endpoint: .v3)
        }
    }
    
    func markAllAsRead() async throws {
        _ = try await performingForEndpoint { endpoint in
            LemmyMarkAllNotificationsReadRequest(endpoint: endpoint)
        }
    }
    
    func getPersonalUnreadCount() async throws -> Int {
        let response = try await performingForEndpoint { endpoint in
            LemmyUnreadCountRequest()
        }
        return response.replies + response.mentions + response.privateMessages
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
            LemmyEditPrivateMessageRequest(
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
