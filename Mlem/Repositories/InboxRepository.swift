//
//  InboxRepository.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Dependencies
import Foundation

/// Repository for inbox items
class InboxRepository {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.hapticManager) var hapticManager
    
    func markAllAsRead() async throws {
        try await apiClient.markAllAsRead()
    }
    
    // MARK: - replies
    
    func loadReplies(
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [ReplyModel] {
        try await apiClient.getReplies(
            sort: .new,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        .map { ReplyModel(from: $0) }
    }
    
    func voteOnCommentReply(_ reply: ReplyModel, vote: ScoringOperation) async throws -> ReplyModel {
        // no haptics here as we defer to the `voteOnComment` method which will produce them if necessary
        do {
            let updatedCommentView = try await commentRepository.voteOnComment(id: reply.comment.id, vote: vote)
            return ReplyModel(
                commentReply: reply.commentReply,
                comment: updatedCommentView.comment,
                creator: UserModel(from: updatedCommentView.creator),
                post: updatedCommentView.post,
                community: CommunityModel(from: updatedCommentView.community),
                recipient: reply.recipient,
                numReplies: updatedCommentView.counts.childCount,
                votes: VotesModel(from: updatedCommentView.counts, myVote: updatedCommentView.myVote),
                creatorBannedFromCommunity: updatedCommentView.creatorBannedFromCommunity,
                subscribed: updatedCommentView.subscribed,
                saved: updatedCommentView.saved,
                creatorBlocked: updatedCommentView.creatorBlocked
            )
        } catch {
            throw error
        }
    }
    
    func markReplyRead(id: Int, isRead: Bool) async throws -> ReplyModel {
        let updatedReply = try await apiClient.markCommentReplyRead(id: id, isRead: isRead)
        return ReplyModel(from: updatedReply.commentReplyView)
    }
    
    // MARK: - mentions
    
    func loadMentions(
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [MentionModel] {
        try await apiClient.getPersonMentions(
            sort: .new,
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        .map { MentionModel(from: $0) }
    }
    
    func markMentionRead(id: Int, isRead: Bool) async throws -> MentionModel {
        let response = try await apiClient.markPersonMentionAsRead(mentionId: id, isRead: isRead)
        return MentionModel(from: response)
    }
    
    func voteOnMention(_ mention: MentionModel, vote: ScoringOperation) async throws -> MentionModel {
        // no haptics here as we defer to the `voteOnComment` method which will produce them if necessary
        do {
            let updatedCommentView = try await commentRepository.voteOnComment(id: mention.comment.id, vote: vote)
            return MentionModel(
                personMention: mention.personMention,
                comment: updatedCommentView.comment,
                creator: mention.creator,
                post: updatedCommentView.post,
                community: CommunityModel(from: updatedCommentView.community),
                recipient: mention.recipient,
                numReplies: updatedCommentView.counts.childCount,
                votes: VotesModel(from: updatedCommentView.counts, myVote: updatedCommentView.myVote),
                creatorBannedFromCommunity: updatedCommentView.creatorBannedFromCommunity,
                subscribed: updatedCommentView.subscribed,
                saved: updatedCommentView.saved,
                creatorBlocked: updatedCommentView.creatorBlocked
            )
        } catch {
            throw error
        }
    }
    
    // MARK: - messages
    
    /// Loads a page of private messages
    /// - Parameters:
    ///   - page: page number to load
    ///   - limit: number of items per page to load
    ///   - unreadOnly: whether to load only unread items (true) or all items (false)
    /// - Returns: [PrivateMessageModel] containing requested messages
    func loadMessages(
        page: Int,
        limit: Int,
        unreadOnly: Bool
    ) async throws -> [MessageModel] {
        try await apiClient.getPrivateMessages(
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        .map { MessageModel(from: $0) }
    }
    
    /// Sends a private message
    /// - Parameters:
    ///   - content: body of the message
    ///   - recipientId: id of the person to whom the message should be sent
    /// - Returns: PrivateMessageModel with the sent message
    func sendMessage(content: String, recipientId: Int) async throws -> MessageModel {
        let response = try await apiClient.sendPrivateMessage(content: content, recipientId: recipientId)
        return MessageModel(from: response.privateMessageView)
    }
    
    /// Marks a private message as read or unread
    /// - Parameters:
    ///   - id: id of the private message to mark as read
    ///   - isRead: whether to mark the private message as read (true) or unread (false)
    /// - Returns: PrivateMessageModel with the updated state of the private message
    func markMessageRead(id: Int, isRead: Bool) async throws -> MessageModel {
        let response = try await apiClient.markPrivateMessageRead(id: id, isRead: isRead)
        return MessageModel(from: response)
    }
    
    // TODO: migrate APIPrivateMessageReportView to middleware model
    /// Reports a private message
    /// - Parameters:
    ///   - id: id of the message to report
    ///   - reason: reason for reporting the message
    /// - Returns: APIPrivateMessageReportView with the report info
    func reportMessage(id: Int, reason: String) async throws -> APIPrivateMessageReportView {
        try await apiClient.reportPrivateMessage(id: id, reason: reason)
    }
    
    // MARK: - comment reports
}
