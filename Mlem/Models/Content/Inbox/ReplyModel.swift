//
//  ReplyModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

// swiftlint:disable file_length

import Dependencies
import Foundation
import SwiftUI

/// Internal representation of a comment reply
class ReplyModel: ObservableObject, ContentIdentifiable {
    @Dependency(\.inboxRepository) var inboxRepository
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    
    @Published var commentReply: APICommentReply
    @Published var comment: APIComment
    var creator: UserModel
    var post: APIPost
    var community: CommunityModel
    var recipient: UserModel
    @Published var numReplies: Int
    @Published var votes: VotesModel
    @Published var commentCreatorBannedFromCommunity: Bool
    @Published var subscribed: APISubscribedStatus
    @Published var read: Bool
    @Published var saved: Bool
    @Published var creatorBlocked: Bool

    var uid: ContentModelIdentifier { .init(contentType: .reply, contentId: commentReply.id) }
    
    // prevents a voting operation from ocurring while another is ocurring
    var voting: Bool = false
    
    init(
        commentReply: APICommentReply,
        comment: APIComment,
        creator: UserModel,
        post: APIPost,
        community: CommunityModel,
        recipient: UserModel,
        numReplies: Int,
        votes: VotesModel,
        creatorBannedFromCommunity: Bool,
        subscribed: APISubscribedStatus,
        read: Bool,
        saved: Bool,
        creatorBlocked: Bool
    ) {
        self.commentReply = commentReply
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.recipient = recipient
        self.numReplies = numReplies
        self.votes = votes
        self.commentCreatorBannedFromCommunity = creatorBannedFromCommunity
        self.subscribed = subscribed
        self.read = read
        self.saved = saved
        self.creatorBlocked = creatorBlocked
    }

    init(from replyView: APICommentReplyView) {
        self.commentReply = replyView.commentReply
        self.comment = replyView.comment
        self.creator = UserModel(from: replyView.creator)
        self.post = replyView.post
        self.community = CommunityModel(from: replyView.community)
        self.recipient = UserModel(from: replyView.recipient)
        self.numReplies = replyView.counts.childCount
        self.votes = VotesModel(from: replyView.counts, myVote: replyView.myVote)
        self.commentCreatorBannedFromCommunity = replyView.creatorBannedFromCommunity
        self.subscribed = replyView.subscribed
        self.read = replyView.commentReply.read
        self.saved = replyView.saved
        self.creatorBlocked = replyView.creatorBlocked
    }
    
    init(
        from replyModel: ReplyModel,
        commentReply: APICommentReply? = nil,
        comment: APIComment? = nil,
        creator: UserModel? = nil,
        post: APIPost? = nil,
        community: CommunityModel? = nil,
        recipient: UserModel? = nil,
        numReplies: Int? = nil,
        votes: VotesModel? = nil,
        creatorBannedFromCommunity: Bool? = nil,
        subscribed: APISubscribedStatus? = nil,
        read: Bool? = nil,
        saved: Bool? = nil,
        creatorBlocked: Bool? = nil
    ) {
        self.commentReply = commentReply ?? replyModel.commentReply
        self.comment = comment ?? replyModel.comment
        self.creator = creator ?? replyModel.creator
        self.post = post ?? replyModel.post
        self.community = community ?? replyModel.community
        self.recipient = recipient ?? replyModel.recipient
        self.numReplies = numReplies ?? replyModel.numReplies
        self.votes = votes ?? replyModel.votes
        self.commentCreatorBannedFromCommunity = creatorBannedFromCommunity ?? replyModel.commentCreatorBannedFromCommunity
        self.subscribed = subscribed ?? replyModel.subscribed
        self.read = read ?? replyModel.read
        self.saved = saved ?? replyModel.saved
        self.creatorBlocked = creatorBlocked ?? replyModel.creatorBlocked
    }
}

extension ReplyModel {
    @MainActor
    func setCommentReply(_ commentReply: APICommentReply) {
        self.commentReply = commentReply
    }
    
    @MainActor
    func setVotes(_ newVotes: VotesModel) {
        votes = newVotes
    }
    
    @MainActor
    func setSaved(_ newSaved: Bool) {
        saved = newSaved
    }
    
    @MainActor
    func setRead(_ newRead: Bool) {
        read = newRead
    }
    
    /// Re-initializes all fields to match the given ReplyModel
    @MainActor
    func reinit(from replyModel: ReplyModel) {
        commentReply = replyModel.commentReply
        comment = replyModel.comment
        creator = replyModel.creator
        post = replyModel.post
        community = replyModel.community
        recipient = replyModel.recipient
        numReplies = replyModel.numReplies
        votes = replyModel.votes
        commentCreatorBannedFromCommunity = replyModel.commentCreatorBannedFromCommunity
        subscribed = replyModel.subscribed
        read = replyModel.read
        saved = replyModel.saved
        creatorBlocked = replyModel.creatorBlocked
    }
    
    func toggleUpvote(unreadTracker: UnreadTracker) async { await vote(inputOp: .upvote, unreadTracker: unreadTracker) }
    func toggleDownvote(unreadTracker: UnreadTracker) async { await vote(inputOp: .downvote, unreadTracker: unreadTracker) }
    
    func vote(inputOp: ScoringOperation, unreadTracker: UnreadTracker) async {
        guard !voting else {
            return
        }
        
        voting = true
        defer { voting = false }
        
        hapticManager.play(haptic: .lightSuccess, priority: .low)
        let operation = votes.myVote == inputOp ? ScoringOperation.resetVote : inputOp
        
        let original: ReplyModel = .init(from: self)
        
        // state fake
        await setVotes(votes.applyScoringOperation(operation: operation))
        await setCommentReply(APICommentReply(from: commentReply, read: true))
        
        do {
            let updatedReply = try await inboxRepository.voteOnCommentReply(self, vote: operation)
            await reinit(from: updatedReply)
            if !original.commentReply.read {
                _ = try await inboxRepository.markReplyRead(id: commentReply.id, isRead: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    unreadTracker.replies.read()
                }
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await reinit(from: original)
        }
    }
    
    func toggleRead(unreadTracker: UnreadTracker) async {
        hapticManager.play(haptic: .lightSuccess, priority: .low)
        
        // store original state
        let originalCommentReply = commentReply
        
        // state fake
        await setCommentReply(APICommentReply(from: commentReply, read: !commentReply.read))
        
        // call API and either update with latest info or revert state fake on fail
        do {
            let newReply = try await inboxRepository.markReplyRead(id: commentReply.id, isRead: commentReply.read)
            await reinit(from: newReply)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                unreadTracker.replies.toggleRead(originalState: originalCommentReply.read)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await setCommentReply(originalCommentReply)
        }
    }
    
    func toggleSave(unreadTracker: UnreadTracker) async {
        hapticManager.play(haptic: .success, priority: .low)
        
        let shouldSave: Bool = !saved
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        // state fake
        let original: ReplyModel = .init(from: self)
        await setSaved(shouldSave)
        await setRead(true)
        if shouldSave, upvoteOnSave, votes.myVote != .upvote {
            await setVotes(votes.applyScoringOperation(operation: .upvote))
        }
        
        // API call
        do {
            let saveResponse = try await inboxRepository.saveCommentReply(self, shouldSave: shouldSave)
            
            if shouldSave, upvoteOnSave {
                let voteResponse = try await inboxRepository.voteOnCommentReply(self, vote: .upvote)
                await reinit(from: voteResponse)
            } else {
                await reinit(from: saveResponse)
            }
            if !original.commentReply.read {
                let newReply = try await inboxRepository.markReplyRead(id: commentReply.id, isRead: true)
                await reinit(from: newReply)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    unreadTracker.replies.read()
                }
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await reinit(from: original)
        }
    }
    
    @MainActor
    func reply(editorTracker: EditorTracker, unreadTracker: UnreadTracker) {
        editorTracker.openEditor(with: ConcreteEditorModel(
            commentReply: self,
            operation: InboxItemOperation.replyToInboxItem
        ))
    }
    
    @MainActor
    func report(editorTracker: EditorTracker, unreadTracker: UnreadTracker) {
        editorTracker.openEditor(with: ConcreteEditorModel(
            commentReply: self,
            operation: InboxItemOperation.reportInboxItem
        ))
    }
    
    func blockUser(userId: Int) async {
        do {
            let response = try await apiClient.blockPerson(id: userId, shouldBlock: true)
            
            if response.blocked {
                hapticManager.play(haptic: .violentSuccess, priority: .high)
                await notifier.add(.success("Blocked user"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block user",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }
    
    // MARK: - Menu functions and swipe actions
    
    // swiftlint:disable function_body_length
    func menuFunctions(
        unreadTracker: UnreadTracker,
        editorTracker: EditorTracker
    ) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        ret.append(MenuFunction.standardMenuFunction(
            text: votes.myVote == .upvote ? "Undo Upvote" : "Upvote",
            imageName: votes.myVote == .upvote ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .upvote, unreadTracker: unreadTracker)
            }
        })
        
        // downvote
        ret.append(MenuFunction.standardMenuFunction(
            text: votes.myVote == .downvote ? "Undo Downvote" : "Downvote",
            imageName: votes.myVote == .downvote ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .downvote, unreadTracker: unreadTracker)
            }
        })
        
        // toggle read
        ret.append(MenuFunction.standardMenuFunction(
            text: commentReply.read ? "Mark Unread" : "Mark Read",
            imageName: commentReply.read ? Icons.markUnread : Icons.markRead,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.toggleRead(unreadTracker: unreadTracker)
            }
        })
        
        // reply
        ret.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await self.reply(editorTracker: editorTracker, unreadTracker: unreadTracker)
            }
        })
        
        // report
        ret.append(MenuFunction.standardMenuFunction(
            text: "Report",
            imageName: Icons.moderationReport,
            isDestructive: true
        ) {
            Task(priority: .userInitiated) {
                await self.report(editorTracker: editorTracker, unreadTracker: unreadTracker)
            }
        })
        
        // block
        ret.append(MenuFunction.standardMenuFunction(
            text: "Block",
            imageName: Icons.userBlock,
            confirmationPrompt: AppConstants.blockUserPrompt
        ) {
            Task(priority: .userInitiated) {
                await self.blockUser(userId: self.creator.id)
            }
        })
        
        return ret
    }

    // swiftlint:enable function_body_length
    
    func swipeActions(
        unreadTracker: UnreadTracker,
        editorTracker: EditorTracker
    ) -> SwipeConfiguration {
        var leadingActions: [SwipeAction] = .init()
        var trailingActions: [SwipeAction] = .init()
        
        leadingActions.append(SwipeAction(
            symbol: .init(
                emptyName: votes.myVote == .upvote ? Icons.resetVoteSquare : Icons.upvoteSquare,
                fillName: votes.myVote == .upvote ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill
            ),
            color: .upvoteColor
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .upvote, unreadTracker: unreadTracker)
            }
        })
        
        leadingActions.append(SwipeAction(
            symbol: .init(
                emptyName: votes.myVote == .downvote ? Icons.resetVoteSquare : Icons.downvoteSquare,
                fillName: votes.myVote == .downvote ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill
            ),
            color: .downvoteColor
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .downvote, unreadTracker: unreadTracker)
            }
        })

        trailingActions.append(SwipeAction(
            symbol: .init(
                emptyName: commentReply.read ? Icons.markRead : Icons.markUnread,
                fillName: commentReply.read ? Icons.markUnreadFill : Icons.markReadFill
            ),
            color: .purple
        ) {
            Task(priority: .userInitiated) {
                await self.toggleRead(unreadTracker: unreadTracker)
            }
        })
        
        trailingActions.append(SwipeAction(
            symbol: .init(emptyName: Icons.reply, fillName: Icons.replyFill),
            color: .upvoteColor
        ) {
            Task(priority: .userInitiated) {
                await self.reply(editorTracker: editorTracker, unreadTracker: unreadTracker)
            }
        })
        
        return SwipeConfiguration(leadingActions: leadingActions, trailingActions: trailingActions)
    }
}

extension ReplyModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(commentReply.read)
        hasher.combine(comment.updated)
        hasher.combine(votes)
        hasher.combine(saved)
    }
}

extension ReplyModel: Identifiable {
    var id: Int { hashValue }
}

extension ReplyModel: Equatable {
    static func == (lhs: ReplyModel, rhs: ReplyModel) -> Bool {
        lhs.id == rhs.id
    }
}

// swiftlint:enable file_length
