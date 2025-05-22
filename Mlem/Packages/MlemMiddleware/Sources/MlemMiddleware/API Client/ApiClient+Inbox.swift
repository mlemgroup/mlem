//
//  ApiClient+Inbox.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

public extension ApiClient {
    func getReplies(
        sort: ApiCommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2] {
        let request = ListRepliesRequest(sort: sort, page: page, limit: limit, unreadOnly: unreadOnly)
        let response = try await perform(request)
        return try await caches.reply2.getModels(
            api: self,
            from: response.replies.map { try .init(from: $0) }
        )
    }
    
    func getMentions(
        sort: ApiCommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2] {
        let request = ListMentionsRequest(sort: sort, page: page, limit: limit, unreadOnly: unreadOnly)
        let response = try await perform(request)
        
        return try await caches.reply2.getModels(
            api: self,
            from: response.mentions.map { try .init(from: $0) }
        )
    }
    
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2] {
        let request = GetPrivateMessageRequest(unreadOnly: unreadOnly, page: page, limit: limit, creatorId: creatorId)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.message2.getModels(
            api: self,
            from: response.privateMessages.map { try .init(from: $0) },
            myPersonId: myPersonId
        )
    }
    
    func markAllAsRead() async throws {
        let request = MarkAllNotificationsReadRequest(endpoint: .v3)
        try await perform(request)
        for reply in caches.reply1.itemCache.value.values {
            reply.content?.readManager.updateWithReceivedValue(true, semaphore: nil)
        }
        for message in caches.message1.itemCache.value.values {
            message.content?.readManager.updateWithReceivedValue(true, semaphore: nil)
        }
        unreadCount?.clear(.personal)
    }
    
    func markReplyAsRead(
        id: Int,
        read: Bool = true,
        semaphore: UInt? = nil
    ) async throws {
        let request = MarkReplyAsReadRequest(endpoint: .v3, commentReplyId: id, read: read)
        try await perform(request)
    }
    
    @discardableResult
    func markMentionAsRead(
        id: Int,
        read: Bool = true,
        semaphore: UInt? = nil
    ) async throws -> Reply2 {
        let request = MarkPersonMentionAsReadRequest(personMentionId: id, read: read)
        let response = try await perform(request)
        return try await caches.reply2.getModel(
            api: self,
            from: .init(from: response.personMentionView),
            semaphore: semaphore
        )
    }
    
    func markMessageAsRead(
        id: Int,
        read: Bool = true,
        semaphore: UInt? = nil
    ) async throws {
        let request = MarkPmAsReadRequest(endpoint: .v3, privateMessageId: id, read: read)
        try await perform(request)
    }
    
    func getPersonalUnreadCount() async throws -> ApiGetUnreadCountResponse {
        try await perform(UnreadCountRequest(endpoint: .v3))
    }
    
    /// Get an ``UnreadCount`` object that continues to be updated by the ``ApiClient`` whenever an inbox item is marked read/unread.
    func getUnreadCount(alwaysMakeCalls: Bool = false) async throws -> UnreadCount {
        let unreadCount = unreadCount ?? .init(api: self)
        try await unreadCount.refresh(alwaysMakeCalls: alwaysMakeCalls)
        self.unreadCount = unreadCount
        return unreadCount
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2 {
        let request = CreatePrivateMessageRequest(endpoint: .v3, content: content, recipientId: personId)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.message2.getModel(
            api: self,
            from: .init(from: response.privateMessageView),
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2 {
        let request = UpdatePrivateMessageRequest(endpoint: .v3, privateMessageId: id, content: content)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.message2.getModel(
            api: self,
            from: .init(from: response.privateMessageView),
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> Report {
        let request = CreatePmReportRequest(endpoint: .v3, privateMessageId: id, reason: reason)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.report.getModel(
            api: self,
            from: .init(from: response.privateMessageReportView),
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func deleteMessage(id: Int, delete: Bool, semaphore: UInt? = nil) async throws -> Message2 {
        let request = DeletePrivateMessageRequest(endpoint: .v3, privateMessageId: id, deleted: delete)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.message2.getModel(
            api: self,
            from: .init(from: response.privateMessageView),
            myPersonId: myPersonId,
            semaphore: semaphore
        )
    }
}
