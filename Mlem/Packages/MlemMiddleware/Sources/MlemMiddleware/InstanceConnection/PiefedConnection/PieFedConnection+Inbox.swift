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
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getMentions(
        sort: CommentSortType = .new,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Reply2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getMessages(
        creatorId: Int? = nil,
        page: Int,
        limit: Int,
        unreadOnly: Bool = false
    ) async throws -> [Message2Snapshot] {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func markAllAsRead() async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func markReplyAsRead(id: Int, read: Bool = true) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func markMentionAsRead(id: Int, read: Bool = true) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func markMessageAsRead(id: Int, read: Bool = true) async throws {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getPersonalUnreadCount() async throws -> PersonalUnreadCountSnapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func createMessage(personId: Int, content: String) async throws -> Message2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func editMessage(id: Int, content: String) async throws -> Message2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func reportMessage(id: Int, reason: String) async throws -> ReportSnapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func deleteMessage(id: Int, delete: Bool) async throws -> Message2Snapshot {
        throw ApiClientError.unsupportedLemmyVersion
    }
}
