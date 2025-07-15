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
        return try response.replies.map { try .init(from: $0) }
    }
    
    func getMentions(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        []
    }
    
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2Snapshot] {
        guard creatorId == nil else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetPrivateMessagesRequest(
            unreadOnly: unreadOnly,
            page: page,
            limit: limit,
            creatorId: nil
        )
        let response = try await perform(request)
        return try response.privateMessages.map { try .init(from: $0) }
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
        throw ApiClientError.featureUnsupported
    }
    
    func markMessageAsRead(id: Int, read: Bool = true) async throws {
        throw ApiClientError.featureUnsupported
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        let request = PieFedGetUnreadCountRequest()
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2Snapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> ReportSnapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func deleteMessage(id: Int, delete: Bool) async throws -> Message2Snapshot {
        throw ApiClientError.featureUnsupported
    }
}
