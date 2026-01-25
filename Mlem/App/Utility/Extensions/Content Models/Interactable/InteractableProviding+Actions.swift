//
//  InteractableProviding+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-24.
//

import MlemMiddleware
import Theming

// Methods to support actions

extension InteractableProviding {
        
    // MARK: Actions
    
    func upvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard let toggleUpvoted, let votes = votes.value else { return nil }
        return .init(id: "upvote\(uid)",
                     appearance: .upvote(isOn: votes.myVote == .upvote),
                     callback: api.canInteract(appState: appState) ? { @MainActor in toggleUpvoted(feedback) } : nil
        )
    }
    
    func downvoteAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard let toggleDownvoted, let votes = votes.value else { return nil }
        return .init(
            id: "downvote\(uid)",
            appearance: .downvote(isOn: votes.myVote == .downvote),
            callback: api.canInteract(appState: appState) && downvotesEnabled
            ? { @MainActor in toggleDownvoted(feedback) }
            : nil
        )
    }
    
    func saveAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction? {
        guard let toggleSaved, let saved = saved.value else { return nil }
        return .init(
            id: "save\(uid)",
            appearance: .save(isOn: saved),
            callback: api.canInteract(appState: appState)
            ? { @MainActor in toggleSaved(feedback) }
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
        guard let creator = creator.value else { return nil }
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
        guard let creator = creator.value else { return nil }
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
        guard let votes = votes.value else { return nil }
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
        guard let votes = votes.value else { return nil }
        let isOn = votes.myVote == .upvote
        return Readout(
            id: "upvote\(uid)",
            label: votes.upvotes.description,
            icon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            color: isOn && showColor ? .themedUpvote : nil
        )
    }
    
    func downvoteReadout(showColor: Bool) -> Readout? {
        guard let votes = votes.value else { return nil }
        let isOn = votes.myVote == .downvote
        return Readout(
            id: "downvote\(uid)",
            label: votes.downvotes.description,
            icon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            color: isOn && showColor ? .themedDownvote : nil
        )
    }
    
    var commentReadout: Readout? {
        guard let unreadCount = (self as? Post)?.unreadCommentCount.value,
              let commentCount = commentCount.value,
              unreadCount > 0, unreadCount != commentCount else {
            return nil
        }
        
        return .init(
            id: "comment\(uid)",
            label: commentCount.description,
            icon: Icons.replies,
            value: "+\(unreadCount)",
            valueColor: .themedPositive
        )
    }
    
    func savedReadout(showColor: Bool) -> Readout? {
        guard let saved = saved.value else { return nil }
        let isOn = saved
        return .init(
            id: "saved\(uid)",
            label: nil,
            icon: isOn ? Icons.saveFill : Icons.save,
            color: isOn && showColor ? .themedSave : nil
        )
    }
    
    // MARK: Counters
    
    func upvoteCounter(appState: AppState) -> Counter? {
        guard let votes = votes.value,
              let upvoteAction = upvoteAction(appState: appState, feedback: [.haptic]) else { return nil }
        return .init(
            value: votes.upvotes,
            leadingAction: upvoteAction,
            trailingAction: nil
        )
    }
    
    func downvoteCounter(appState: AppState, downvotesEnabled: Bool) -> Counter? {
        guard let votes = votes.value,
              let downvoteAction = downvoteAction(
                appState: appState,
                feedback: [.haptic]) else { return nil }
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
        guard let votes = votes.value,
              let upvoteAction = upvoteAction(appState: appState, feedback: [.haptic]) else { return nil }
        return .init(
            value: votes.total,
            leadingAction: upvoteAction,
            trailingAction: downvoteAction(
                appState: appState,
                feedback: [.haptic]
            )
        )
    }
    
    func replyCounter(appState: AppState, commentTreeTracker: CommentTreeTracker? = nil) -> Counter? {
        guard let commentCount = self.commentCount.value else { return nil }
        return .init(
            value: commentCount,
            leadingAction: replyAction(appState: appState, commentTreeTracker: commentTreeTracker),
            trailingAction: nil
        )
    }
}
