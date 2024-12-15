//
//  Interactable1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import MlemMiddleware
import SwiftUI

extension Interactable1Providing {
    private var self2: (any Interactable2Providing)? { self as? any Interactable2Providing }
    private var inboxItem: (any InboxItemProviding)? { self as? any InboxItemProviding }
    
    func showReplySheet(commentTreeTracker: CommentTreeTracker? = nil) {
        if let responseContext {
            NavigationModel.main.openSheet(.createComment(responseContext, commentTreeTracker: commentTreeTracker))
        } else {
            print("DEBUG showReplySheet: cannot open sheet!")
        }
    }
    
    private var responseContext: CommentEditorView.Context? {
        if let self = self as? any Post2Providing { return .post(self) }
        if let self = self as? any Comment2Providing { return .comment(self) }
        if let self = self as? any Reply2Providing { return .comment(self.comment) }
        return nil
    }
    
    func toggleUpvoted(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            }
            self2.toggleUpvoted()
            inboxItem?.updateRead(true)
        } else {
            print("DEBUG no self2 found in toggleUpvote!")
        }
    }
    
    func toggleDownvoted(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            }
            self2.toggleDownvoted()
            inboxItem?.updateRead(true)
        } else {
            print("DEBUG no self2 found in toggleDownvote!")
        }
    }
    
    func toggleSaved(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .success, priority: .low)
            }
            @Setting(\.upvoteOnSave) var upvoteOnSave
            if upvoteOnSave, !self2.saved, self2.votes.myVote != .upvote {
                self2.updateVote(.upvote)
            }
            
            self2.toggleSaved()
            inboxItem?.updateRead(true)
        } else {
            print("DEBUG no self2 found in toggleSave!")
        }
    }
    
    func toggleRemoved(reason: String?, feedback: Set<FeedbackType>) {
        guard let self2 else {
            print("DEBUG no self2 found in toggleRemoved!")
            return
        }
        Task {
            let initialValue = self2.removed
            if feedback.contains(.haptic) {
                await HapticManager.main.play(haptic: .success, priority: .low)
            }
            switch await self2.toggleRemoved(reason: reason).result.get() {
            case .failed:
                ToastModel.main.add(.failure(initialValue ? "Failed to remove content" : "Failed to restore content"))
            default:
                break
            }
        }
    }

    // MARK: Counters
    
    var upvoteCounter: Counter {
        .init(
            value: self2?.votes.upvotes,
            leadingAction: upvoteAction(feedback: [.haptic]),
            trailingAction: nil
        )
    }
    
    var downvoteCounter: Counter {
        .init(
            value: self2?.votes.downvotes,
            leadingAction: downvoteAction(feedback: [.haptic]),
            trailingAction: nil
        )
    }
    
    var scoreCounter: Counter {
        .init(
            value: self2?.votes.total,
            leadingAction: upvoteAction(feedback: [.haptic]),
            trailingAction: api.downvotesEnabled ? downvoteAction(feedback: [.haptic]) : nil
        )
    }
    
    func replyCounter(commentTreeTracker: CommentTreeTracker? = nil) -> Counter {
        .init(
            value: self2?.commentCount,
            leadingAction: replyAction(commentTreeTracker: commentTreeTracker),
            trailingAction: nil
        )
    }
    
    // MARK: Actions
    
    func upvoteAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "upvote\(uid)",
            appearance: .upvote(isOn: self2?.votes.myVote ?? .none == .upvote),
            callback: api.canInteract ? { self.self2?.toggleUpvoted(feedback: feedback) } : nil
        )
    }
    
    func downvoteAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let enabled = api.canInteract && api.downvotesEnabled
        return .init(
            id: "downvote\(uid)",
            appearance: .downvote(isOn: self2?.votes.myVote ?? .none == .downvote),
            callback: enabled ? { self.self2?.toggleDownvoted(feedback: feedback) } : nil
        )
    }
    
    func saveAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "save\(uid)",
            appearance: .save(isOn: self2?.saved ?? false),
            callback: api.canInteract ? { self.self2?.toggleSaved(feedback: feedback) } : nil
        )
    }
    
    func replyAction(commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
        .init(
            id: "reply\(uid)",
            appearance: .reply(),
            callback: api.canInteract ? { self.showReplySheet(commentTreeTracker: commentTreeTracker) } : nil
        )
    }
    
    func blockCreatorAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCreator\(uid)",
            appearance: .blockCreator(),
            confirmationPrompt: showConfirmation ? "Really block this user?" : nil,
            callback: api.canInteract ? { self.self2?.creator.toggleBlocked(feedback: feedback) } : nil
        )
    }
    
    func banActions() -> [any Action] {
        let isModerator: Bool
        if let myPerson = api.myPerson, let community = community_ {
            isModerator = myPerson.moderates(communityId: community.id)
        } else {
            isModerator = false
        }
        var output: [any Action] = .init()
        // admins should see separate 'ban' and 'unban' actions if ban statuses conflict; otherwise actions are grouped under a single entry (community or instance, depending on moderation status)
        let showBoth: Bool = api.isAdmin && (bannedFromCommunity_ ?? false) != (creator_?.bannedFromInstance ?? false)
        // moderators see community ban action by default, regardless of admin status
        if isModerator {
            if showBoth {
                output.append(banCreatorFromInstanceAction())
            }
            output.append(banCreatorFromCommunityAction())
        }
        // non-moderator admins see instance ban action by default
        else if api.isAdmin {
            output.append(banCreatorFromInstanceAction())
            if showBoth {
                output.append(banCreatorFromCommunityAction())
            }
        }
        return output
    }
    
    func banCreatorFromInstanceAction() -> BasicAction {
        .init(
            id: "banCreatorFromInstance\(uid)",
            appearance: .banCreatorFromInstance(isOn: creator_?.bannedFromInstance ?? false),
            callback: api.canInteract && api.isAdmin ? {
                self.self2?.creator.showBanSheet(
                    community: self.self2?.community,
                    isBannedFromCommunity: self.bannedFromCommunity_ ?? false,
                    shouldBan: !(self.creator_?.bannedFromInstance ?? false)
                )
            } : nil
        )
    }
    
    func banCreatorFromCommunityAction() -> BasicAction {
        .init(
            id: "banCreatorFromCommunity\(uid)",
            appearance: .banCreatorFromCommunity(isOn: self2?.bannedFromCommunity ?? false),
            callback: api.canInteract && (self2?.canModerate ?? false) ? {
                self.self2?.creator.showBanSheet(
                    community: self.self2?.community,
                    isBannedFromCommunity: self.bannedFromCommunity_ ?? false,
                    shouldBan: !(self.self2?.bannedFromCommunity ?? false)
                )
            } : nil
        )
    }
    
    func purgeCreatorAction() -> BasicAction {
        .init(
            id: "purgeCreator\(uid)",
            appearance: .purgePerson(),
            callback: (api.canInteract && api.isAdmin) ? self2?.creator.showPurgeSheet : nil
        )
    }
    
    // MARK: Readouts
    
    var createdReadout: Readout {
        .init(
            id: "created\(uid)",
            label: (updated ?? created).getShortRelativeTime(),
            icon: updated == nil ? Icons.time : Icons.updated
        )
    }
    
    var scoreReadout: Readout {
        let icon: String
        let color: Color?
        switch self2?.votes.myVote {
        case .upvote:
            icon = Icons.upvoteSquareFill
            color = Palette.main.upvote
        case .downvote:
            icon = Icons.downvoteSquareFill
            color = Palette.main.downvote
        default:
            icon = Icons.upvoteSquare
            color = nil
        }
        return Readout(
            id: "score\(uid)",
            label: self2?.votes.total.description,
            icon: icon,
            color: color
        )
    }
    
    var upvoteReadout: Readout {
        let isOn = self2?.votes.myVote == .upvote
        return Readout(
            id: "upvote\(uid)",
            label: self2?.votes.upvotes.description,
            icon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            color: isOn ? Palette.main.upvote : nil
        )
    }
    
    var downvoteReadout: Readout {
        let isOn = self2?.votes.myVote == .downvote
        return Readout(
            id: "downvote\(uid)",
            label: self2?.votes.downvotes.description,
            icon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            color: isOn ? Palette.main.downvote : nil
        )
    }
    
    var commentReadout: Readout {
        let value: String?
        if let unreadCount = (self as? any Post1Providing)?.unreadCommentCount_,
           unreadCount > 0, unreadCount != commentCount_ {
            value = "+\(unreadCount)"
        } else {
            value = nil
        }
        
        return .init(
            id: "comment\(uid)",
            label: self2?.commentCount.description,
            icon: Icons.replies,
            value: value,
            valueColor: Palette.main.positive
        )
    }
    
    var savedReadout: Readout {
        let isOn = saved_ ?? false
        return .init(
            id: "saved\(uid)",
            label: nil,
            icon: isOn ? Icons.saveFill : Icons.save,
            color: isOn ? Palette.main.save : nil
        )
    }
}
