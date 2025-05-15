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
        let request = GetRepliesRequest(sort: sort, page: page, limit: limit, unreadOnly: unreadOnly)
        let response = try await perform(request)
        return await caches.reply2.getModels(api: self, from: response.replies)
    }
    
    func getMentions(
        sort: ApiCommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2] {
        let request = GetPersonMentionsRequest(sort: sort, page: page, limit: limit, unreadOnly: unreadOnly)
        let response = try await perform(request)
        return await caches.reply2.getModels(api: self, from: response.mentions)
    }
    
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2] {
        let request = GetPrivateMessagesRequest(unreadOnly: unreadOnly, page: page, limit: limit, creatorId: creatorId)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.message2.getModels(
            api: self,
            from: response.privateMessages,
            myPersonId: myPersonId
        )
    }
    
    func markAllAsRead() async throws {
        let request = MarkAllNotificationsAsReadRequest(endpoint: .v3)
        try await perform(request)
        for reply in caches.reply1.itemCache.value.values {
            reply.content?.readManager.updateWithReceivedValue(true, semaphore: nil)
        }
        for message in caches.message1.itemCache.value.values {
            message.content?.readManager.updateWithReceivedValue(true, semaphore: nil)
        }
        unreadCount?.clear(.personal)
    }
    
    @discardableResult
    func markReplyAsRead(
        id: Int,
        read: Bool = true,
        semaphore: UInt? = nil
    ) async throws -> Reply2 {
        let request = MarkCommentReplyAsReadRequest(endpoint: .v3, commentReplyId: id, read: read)
        let response = try await perform(request)
        return await caches.reply2.getModel(api: self, from: response.commentReplyView, semaphore: semaphore)
    }
    
    @discardableResult
    func markMentionAsRead(
        id: Int,
        read: Bool = true,
        semaphore: UInt? = nil
    ) async throws -> Reply2 {
        let request = MarkPersonMentionAsReadRequest(personMentionId: id, read: read)
        let response = try await perform(request)
        return await caches.reply2.getModel(api: self, from: response.personMentionView, semaphore: semaphore)
    }
    
    @discardableResult
    func markMessageAsRead(
        id: Int,
        read: Bool = true,
        semaphore: UInt? = nil
    ) async throws -> Message2 {
        let request = MarkPrivateMessageAsReadRequest(endpoint: .v3, privateMessageId: id, read: read)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.message2.getModel(
            api: self,
            from: response.privateMessageView,
            myPersonId: myPersonId,
            semaphore: semaphore
        )
    }
    
    func getPersonalUnreadCount() async throws -> ApiGetUnreadCountResponse {
        try await perform(GetUnreadCountRequest(endpoint: .v3))
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
            from: response.privateMessageView,
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2 {
        let request = EditPrivateMessageRequest(endpoint: .v3, privateMessageId: id, content: content)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.message2.getModel(
            api: self,
            from: response.privateMessageView,
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> Report {
        let request = CreatePrivateMessageReportRequest(endpoint: .v3, privateMessageId: id, reason: reason)
        async let response = try await perform(request)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return try await caches.report.getModel(
            api: self,
            from: response.privateMessageReportView,
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
            from: response.privateMessageView,
            myPersonId: myPersonId,
            semaphore: semaphore
        )
    }
}
