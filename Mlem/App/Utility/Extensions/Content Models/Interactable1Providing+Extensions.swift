//
//  Interactable1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import Haptics
import MlemMiddleware
import SwiftUI
import Theming

extension Interactable1Providing {
    private var self2: (any Interactable2Providing)? { self as? any Interactable2Providing }
    private var inboxItem: (any InboxItemProviding)? { self as? any InboxItemProviding }
    
    @MainActor
    func showReplySheet(commentTreeTracker: CommentTreeTracker? = nil) {
        if let responseContext {
            NavigationModel.main.openSheet(.createComment(responseContext, commentTreeTracker: commentTreeTracker))
        } else {
            handleError(MlemError.navigationError("Cannot open sheet"), silent: true)
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
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            }
            self2.toggleUpvoted()
            inboxItem?.updateRead(true)
        } else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
        }
    }
    
    func toggleDownvoted(feedback: Set<FeedbackType>) {
        if let self2 {
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            }
            self2.toggleDownvoted()
            inboxItem?.updateRead(true)
            
        } else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
        }
    }
    
    func toggleSaved(feedback: Set<FeedbackType>) {
        // TODO: UpdateQueue remove this shim code
        if let post = self2 as? Post2 {
            @Setting(\.behavior_upvoteOnSave) var upvoteOnSave
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .success, tier: .low)
            }
            if upvoteOnSave, !post.saved, post.votes.myVote != .upvote {
                post.updateVote(.upvote)
            }
            post.updateSaved(!post.saved)
        } else {
            if let self2 {
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .success, tier: .low)
                }
                @Setting(\.behavior_upvoteOnSave) var upvoteOnSave
                if upvoteOnSave, !self2.saved, self2.votes.myVote != .upvote {
                    self2.updateVote(.upvote)
                }
                
                self2.toggleSaved()
                inboxItem?.updateRead(true)
            } else {
                handleError(MlemError.modelError("No self2 found"), silent: true)
            }
        }
    }
    
    func toggleRemoved(reason: String?, feedback: Set<FeedbackType>) {
        guard let self2 else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
            return
        }
        Task {
            let initialValue = self2.removed
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .success, tier: .low)
            }
            self2.toggleRemoved(reason: reason) { status in
                if case .failure = status {
                    ToastModel.main.add(.failure(initialValue ? "Failed to remove content" : "Failed to restore content"))
                }
            }
            
        }
    }
    
    // MARK: Counters
    
    func upvoteCounter(appState: AppState) -> Counter {
        .init(
            value: self2?.votes.upvotes,
            leadingAction: upvoteAction(appState: appState, feedback: [.haptic]),
            trailingAction: nil
        )
    }
    
    func downvoteCounter(appState: AppState) -> Counter {
        .init(
            value: self2?.votes.downvotes,
            leadingAction: downvoteAction(appState: appState, feedback: [.haptic]),
            trailingAction: nil
        )
    }
    
    func scoreCounter(appState: AppState) -> Counter {
        .init(
            value: self2?.votes.total,
            leadingAction: upvoteAction(appState: appState, feedback: [.haptic]),
            trailingAction: api.downvotesEnabled ? downvoteAction(appState: appState, feedback: [.haptic]) : nil
        )
    }
    
    func replyCounter(appState: AppState, commentTreeTracker: CommentTreeTracker? = nil) -> Counter {
        .init(
            value: self2?.commentCount,
            leadingAction: replyAction(appState: appState, commentTreeTracker: commentTreeTracker),
            trailingAction: nil
        )
    }
    
    // MARK: Actions
    
    func upvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "upvote\(uid)",
            appearance: .upvote(isOn: self2?.votes.myVote ?? .none == .upvote),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.self2?.toggleUpvoted(feedback: feedback) } : nil
        )
    }
    
    func downvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        let enabled = api.canInteract(appState: appState) && api.downvotesEnabled
        return .init(
            id: "downvote\(uid)",
            appearance: .downvote(isOn: self2?.votes.myVote ?? .none == .downvote),
            callback: enabled ? { @MainActor in self.self2?.toggleDownvoted(feedback: feedback) } : nil
        )
    }
    
    func saveAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "save\(uid)",
            appearance: .save(isOn: self2?.saved ?? false),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.self2?.toggleSaved(feedback: feedback) } : nil
        )
    }
    
    func replyAction(appState: AppState, commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
        .init(
            id: "reply\(uid)",
            appearance: .reply(),
            callback: api.canInteract(appState: appState) ? { @MainActor in
                self.showReplySheet(commentTreeTracker: commentTreeTracker)
            } : nil
        )
    }
    
    func blockCreatorAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCreator\(uid)",
            appearance: .blockCreator(),
            confirmationPrompt: showConfirmation ? "Really block this user?" : nil,
            callback: api.canInteract(appState: appState) ? { @MainActor in self.self2?.creator.toggleBlocked(feedback: feedback) } : nil
        )
    }
    
    func purgeCreatorAction(appState: AppState) -> BasicAction {
        .init(
            id: "purgeCreator\(uid)",
            appearance: .purgePerson(),
            callback: (api.canInteract(appState: appState) && api.isAdmin) ? self2?.creator.showPurgeSheet : nil
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
    
    func scoreReadout(showColor: Bool) -> Readout {
        let icon: String
        let color: ThemedColor?
        switch self2?.votes.myVote {
        case .upvote:
            icon = Icons.upvoteSquareFill
            color = .themedUpvote
        case .downvote:
            icon = Icons.downvoteSquareFill
            color = .themedDownvote
        default:
            icon = Icons.upvoteSquare
            color = nil
        }
        return Readout(
            id: "score\(uid)",
            label: self2?.votes.total.description,
            icon: icon,
            color: showColor ? color : nil
        )
    }
    
    func upvoteReadout(showColor: Bool) -> Readout {
        let isOn = self2?.votes.myVote == .upvote
        return Readout(
            id: "upvote\(uid)",
            label: self2?.votes.upvotes.description,
            icon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            color: isOn && showColor ? .themedUpvote : nil
        )
    }
    
    func downvoteReadout(showColor: Bool) -> Readout {
        let isOn = self2?.votes.myVote == .downvote
        return Readout(
            id: "downvote\(uid)",
            label: self2?.votes.downvotes.description,
            icon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            color: isOn && showColor ? .themedDownvote : nil
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
            valueColor: .themedPositive
        )
    }
    
    func savedReadout(showColor: Bool) -> Readout {
        let isOn = saved_ ?? false
        return .init(
            id: "saved\(uid)",
            label: nil,
            icon: isOn ? Icons.saveFill : Icons.save,
            color: isOn && showColor ? .themedSave : nil
        )
    }
}
