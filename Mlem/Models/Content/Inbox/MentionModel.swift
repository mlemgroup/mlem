//
//  MentionModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//

import Dependencies
import Foundation
import SwiftUI

// swiftlint:disable file_length

/// Internal representation of a person mention
class MentionModel: ContentIdentifiable, ObservableObject {
    @Dependency(\.inboxRepository) var inboxRepository
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    
    @Published var personMention: APIPersonMention
    @Published var comment: APIComment
    var creator: UserModel
    var post: APIPost
    var community: CommunityModel
    var recipient: APIPerson
    @Published var numReplies: Int
    @Published var votes: VotesModel
    @Published var creatorBannedFromCommunity: Bool
    @Published var subscribed: APISubscribedStatus
    @Published var read: Bool
    @Published var saved: Bool
    @Published var creatorBlocked: Bool
    
    // prevents a voting operation from ocurring while another is ocurring
    var voting: Bool = false
    
    var uid: ContentModelIdentifier { .init(contentType: .mention, contentId: personMention.id) }
    
    init(
        personMention: APIPersonMention,
        comment: APIComment,
        creator: UserModel,
        post: APIPost,
        community: CommunityModel,
        recipient: APIPerson,
        numReplies: Int,
        votes: VotesModel,
        creatorBannedFromCommunity: Bool,
        subscribed: APISubscribedStatus,
        read: Bool,
        saved: Bool,
        creatorBlocked: Bool
    ) {
        self.personMention = personMention
        self.comment = comment
        self.creator = creator
        self.post = post
        self.community = community
        self.recipient = recipient
        self.numReplies = numReplies
        self.votes = votes
        self.creatorBannedFromCommunity = creatorBannedFromCommunity
        self.subscribed = subscribed
        self.read = read
        self.saved = saved
        self.creatorBlocked = creatorBlocked
    }
    
    init(from personMentionView: APIPersonMentionView) {
        self.personMention = personMentionView.personMention
        self.comment = personMentionView.comment
        self.creator = UserModel(from: personMentionView.creator)
        self.post = personMentionView.post
        self.community = CommunityModel(from: personMentionView.community)
        self.recipient = personMentionView.recipient
        self.numReplies = personMentionView.counts.childCount
        self.votes = VotesModel(from: personMentionView.counts, myVote: personMentionView.myVote)
        self.creatorBannedFromCommunity = personMentionView.creatorBannedFromCommunity
        self.subscribed = personMentionView.subscribed
        self.read = personMentionView.personMention.read
        self.saved = personMentionView.saved
        self.creatorBlocked = personMentionView.creatorBlocked
    }
    
    init(
        from mentionModel: MentionModel,
        personMention: APIPersonMention? = nil,
        comment: APIComment? = nil,
        creator: UserModel? = nil,
        post: APIPost? = nil,
        community: CommunityModel? = nil,
        recipient: APIPerson? = nil,
        numReplies: Int? = nil,
        votes: VotesModel? = nil,
        creatorBannedFromCommunity: Bool? = nil,
        subscribed: APISubscribedStatus? = nil,
        read: Bool? = nil,
        saved: Bool? = nil,
        creatorBlocked: Bool? = nil
    ) {
        self.personMention = personMention ?? mentionModel.personMention
        self.comment = comment ?? mentionModel.comment
        self.creator = creator ?? mentionModel.creator
        self.post = post ?? mentionModel.post
        self.community = community ?? mentionModel.community
        self.recipient = recipient ?? mentionModel.recipient
        self.numReplies = numReplies ?? mentionModel.numReplies
        self.votes = votes ?? mentionModel.votes
        self.creatorBannedFromCommunity = creatorBannedFromCommunity ?? mentionModel.creatorBannedFromCommunity
        self.subscribed = subscribed ?? mentionModel.subscribed
        self.read = read ?? mentionModel.read
        self.saved = saved ?? mentionModel.saved
        self.creatorBlocked = creatorBlocked ?? mentionModel.creatorBlocked
    }
}

extension MentionModel {
    @MainActor
    func setPersonMention(_ personMention: APIPersonMention) {
        self.personMention = personMention
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
    
    /// Re-initializes all fields to match the given MentionModel
    @MainActor
    func reinit(from mentionModel: MentionModel) {
        personMention = mentionModel.personMention
        comment = mentionModel.comment
        creator = mentionModel.creator
        post = mentionModel.post
        community = mentionModel.community
        recipient = mentionModel.recipient
        votes = mentionModel.votes
        creatorBannedFromCommunity = mentionModel.creatorBannedFromCommunity
        subscribed = mentionModel.subscribed
        saved = mentionModel.saved
        creatorBlocked = mentionModel.creatorBlocked
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
        
        let original: MentionModel = .init(from: self)
        
        // state fake
        await setVotes(votes.applyScoringOperation(operation: operation))
        await setPersonMention(APIPersonMention(from: personMention, read: true))
        
        do {
            let updatedMention = try await inboxRepository.voteOnMention(self, vote: operation)
            await reinit(from: updatedMention)
            if !original.personMention.read {
                _ = try await inboxRepository.markMentionRead(id: personMention.id, isRead: true)
                await unreadTracker.readMention()
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
        let originalPersonMention = APIPersonMention(from: personMention)
        
        // state fake
        await setPersonMention(APIPersonMention(from: personMention, read: !personMention.read))
        
        // call API and either update with latest info or revert state fake on fail
        do {
            let newMessage = try await inboxRepository.markMentionRead(id: personMention.id, isRead: personMention.read)
            await reinit(from: newMessage)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                unreadTracker.toggleMentionRead(originalState: originalPersonMention.read)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            await setPersonMention(originalPersonMention)
        }
    }
    
    func toggleSave(unreadTracker: UnreadTracker) async {
        hapticManager.play(haptic: .success, priority: .low)
        
        let shouldSave: Bool = !saved
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        
        // state fake
        let original: MentionModel = .init(from: self)
        await setSaved(shouldSave)
        await setRead(true)
        if shouldSave, upvoteOnSave, votes.myVote != .upvote {
            await setVotes(votes.applyScoringOperation(operation: .upvote))
        }
        
        // API call
        do {
            let saveResponse = try await inboxRepository.saveMention(self, shouldSave: shouldSave)
            
            if shouldSave, upvoteOnSave {
                let voteResponse = try await inboxRepository.voteOnMention(self, vote: .upvote)
                await reinit(from: voteResponse)
            } else {
                await reinit(from: saveResponse)
            }
            if !original.personMention.read {
                _ = try await inboxRepository.markMentionRead(id: personMention.id, isRead: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    unreadTracker.toggleMentionRead(originalState: original.read)
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
            mention: self,
            operation: InboxItemOperation.replyToInboxItem
        ))
        
        // replying to a message marks it as read, but the call doesn't return anything so we just state fake it here
        if !personMention.read {
            setPersonMention(APIPersonMention(from: personMention, read: true))
            unreadTracker.readMention()
        }
    }
    
    @MainActor
    func report(editorTracker: EditorTracker, unreadTracker: UnreadTracker) {
        editorTracker.openEditor(with: ConcreteEditorModel(
            mention: self,
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
            imageName: votes.myVote == .upvote ? Icons.upvoteSquareFill : Icons.upvoteSquare
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .upvote, unreadTracker: unreadTracker)
            }
        })
        
        // downvote
        ret.append(MenuFunction.standardMenuFunction(
            text: votes.myVote == .downvote ? "Undo Downvote" : "Downvote",
            imageName: votes.myVote == .downvote ? Icons.downvoteSquareFill : Icons.downvoteSquare
        ) {
            Task(priority: .userInitiated) {
                await self.vote(inputOp: .downvote, unreadTracker: unreadTracker)
            }
        })
        
        // toggle read
        ret.append(MenuFunction.standardMenuFunction(
            text: personMention.read ? "Mark Unread" : "Mark Read",
            imageName: personMention.read ? Icons.markUnread : Icons.markRead
        ) {
            Task(priority: .userInitiated) {
                await self.toggleRead(unreadTracker: unreadTracker)
            }
        })
        
        // reply
        ret.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply
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
                emptyName: personMention.read ? Icons.markRead : Icons.markUnread,
                fillName: personMention.read ? Icons.markUnreadFill : Icons.markReadFill
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

extension MentionModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(personMention.read)
        hasher.combine(comment.updated)
        hasher.combine(comment.deleted)
        hasher.combine(votes)
        hasher.combine(saved)
    }
}

extension MentionModel: Identifiable {
    var id: Int { hashValue }
}

extension MentionModel: Equatable {
    static func == (lhs: MentionModel, rhs: MentionModel) -> Bool {
        lhs.id == rhs.id
    }
}

// swiftlint:enable file_length
