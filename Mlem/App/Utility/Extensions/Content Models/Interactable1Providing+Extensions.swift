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
    private var self2: (any ShimInteractable2Providing)? { self as? any ShimInteractable2Providing }
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
        if let self = self as? Post { return .post(self) }
        if let self = self as? any Comment2Providing { return .comment(self) }
        if let self = self as? any Reply2Providing { return .comment(self.comment) }
        return nil
    }
    
    func toggleUpvoted(feedback: Set<FeedbackType>) {
        guard let self2, let toggleUpvoted = self2.shimToggleUpvoted else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
            return
        }
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .lightSuccess, tier: .low)
        }
        toggleUpvoted()
        inboxItem?.updateRead(true)
    }
    
    func toggleDownvoted(feedback: Set<FeedbackType>) {
        guard let self2, let toggleDownvoted = self2.shimToggleDownvoted else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
            return
        }
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .lightSuccess, tier: .low)
        }
        toggleDownvoted()
        inboxItem?.updateRead(true)
    }
    
    func toggleSaved(feedback: Set<FeedbackType>) {
        guard let self2,
              let saved = self2.saved.value,
              let votes = self2.votes.value,
              let updateVote = self2.updateVote,
              let toggleSaved = self2.shimToggleSaved else {
            handleError(MlemError.modelError("No self2 found"), silent: true)
            return
        }
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .success, tier: .low)
        }
        @Setting(\.behavior_upvoteOnSave) var upvoteOnSave
        if upvoteOnSave, !saved, votes.myVote != .upvote {
            updateVote(.upvote)
        }
        
        toggleSaved()
        inboxItem?.updateRead(true)
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
    
    func upvoteCounter(appState: AppState) -> Counter? {
        guard let votes = self2?.votes.value,
                let upvoteAction = upvoteAction(appState: appState, feedback: [.haptic]) else { return nil }
        return .init(
            value: votes.upvotes,
            leadingAction: upvoteAction,
            trailingAction: nil
        )
    }
    
    func downvoteCounter(appState: AppState, downvotesEnabled: Bool) -> Counter? {
        guard let votes = self2?.votes.value,
              let downvoteAction = downvoteAction(
                appState: appState,
                feedback: [.haptic],
                downvotesEnabled: downvotesEnabled) else { return nil }
        return .init(
            value: votes.downvotes,
            leadingAction: downvoteAction,
            trailingAction: nil
        )
    }
    
    func scoreCounter(
        appState: AppState,
        downvotesEnabled: Bool
    ) -> Counter? {
        guard let votes = self2?.votes.value,
              let upvoteAction = upvoteAction(appState: appState, feedback: [.haptic]) else { return nil }
        return .init(
            value: votes.total,
            leadingAction: upvoteAction,
            trailingAction: downvoteAction(
                appState: appState,
                feedback: [.haptic],
                downvotesEnabled: downvotesEnabled
            )
        )
    }
    
    func replyCounter(appState: AppState, commentTreeTracker: CommentTreeTracker? = nil) -> Counter? {
        guard let commentCount = self2?.commentCount.value else { return nil }
        return .init(
            value: commentCount,
            leadingAction: replyAction(appState: appState, commentTreeTracker: commentTreeTracker),
            trailingAction: nil
        )
    }
    
    // MARK: Actions
    
    func upvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard let votes = self2?.votes.value else { return nil }
        return .init(
            id: "upvote\(uid)",
            appearance: .upvote(isOn: votes.myVote == .upvote),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.toggleUpvoted(feedback: feedback) } : nil
        )
    }
    
    func downvoteAction(
        appState: AppState,
        feedback: Set<FeedbackType> = [],
        downvotesEnabled: Bool
    ) -> BasicAction? {
        guard let votes = self2?.votes.value else { return nil }
        return .init(
            id: "downvote\(uid)",
            appearance: .downvote(isOn: votes.myVote == .downvote),
            callback: (api.canInteract(appState: appState) && downvotesEnabled)
            ? { @MainActor in self.toggleDownvoted(feedback: feedback) }
            : nil
        )
    }
    
    func saveAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard let saved = self2?.saved.value else { return nil }
        return .init(
            id: "save\(uid)",
            appearance: .save(isOn: saved),
            callback: api.canInteract(appState: appState)
            ? { @MainActor in self.toggleSaved(feedback: feedback) }
            : nil
        )
    }
    
    func replyAction(appState: AppState, commentTreeTracker: CommentTreeTracker? = nil) -> BasicAction {
        return .init(
            id: "reply\(uid)",
            appearance: .reply(),
            callback: api.canInteract(appState: appState)
            ? { @MainActor in self.showReplySheet(commentTreeTracker: commentTreeTracker) }
            : nil
        )
    }
    
    func blockCreatorAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction? {
        guard let creator = self2?.creator.value else { return nil }
        return .init(
            id: "blockCreator\(uid)",
            appearance: .blockCreator(),
            confirmationPrompt: showConfirmation ? "Really block this user?" : nil,
            callback: api.canInteract(appState: appState)
            ? { @MainActor in creator.toggleBlocked(feedback: feedback) }
            : nil
        )
    }
    
    func purgeCreatorAction(appState: AppState) -> BasicAction? {
        guard let creator = self2?.creator.value else { return nil }
        return .init(
            id: "purgeCreator\(uid)",
            appearance: .purgePerson(),
            callback: api.canInteract(appState: appState) && api.isAdmin
            ? { @MainActor in creator.showPurgeSheet() }
            : nil
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
    
    func scoreReadout(showColor: Bool) -> Readout? {
        guard let votes = self2?.votes.value else { return nil }
        let icon: String
        let color: ThemedColor?
        switch votes.myVote {
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
            label: votes.total.description,
            icon: icon,
            color: showColor ? color : nil
        )
    }
    
    func upvoteReadout(showColor: Bool) -> Readout? {
        guard let votes = self2?.votes.value else { return nil }
        let isOn = votes.myVote == .upvote
        return Readout(
            id: "upvote\(uid)",
            label: votes.upvotes.description,
            icon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            color: isOn && showColor ? .themedUpvote : nil
        )
    }
    
    func downvoteReadout(showColor: Bool) -> Readout? {
        guard let votes = self2?.votes.value else { return nil }
        let isOn = votes.myVote == .downvote
        return Readout(
            id: "downvote\(uid)",
            label: votes.downvotes.description,
            icon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            color: isOn && showColor ? .themedDownvote : nil
        )
    }
    
    var commentReadout: Readout {
        let value: String?
        if let unreadCount = (self as? Post)?.unreadCommentCount.value,
           unreadCount > 0, unreadCount != commentCount_ {
            value = "+\(unreadCount)"
        } else {
            value = nil
        }
        
        return .init(
            id: "comment\(uid)",
            label: (commentCount_ ?? 0).description,
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
