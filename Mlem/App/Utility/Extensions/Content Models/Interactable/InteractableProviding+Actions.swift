//
//  InteractableProviding+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-24.
//

import MlemMiddleware
import Theming
import os

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
        guard let commentCount = commentCount.value else { return nil }
        
        let value: String?
        if let unreadCount = (self as? Post)?.unreadCommentCount.value,
           unreadCount > 0,
           unreadCount != commentCount {
            value = "+\(unreadCount)"
        } else {
            value = nil
        }
        
        return .init(
            id: "comment\(uid)",
            label: commentCount.description,
            icon: Icons.replies,
            value: value,
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
            leadingAction: .upvote,
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
            leadingAction: .downvote,
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
            leadingAction: .upvote,
            trailingAction: .downvote
        )
    }
    
    func replyCounter(appState: AppState, commentTreeTracker: CommentTreeTracker? = nil) -> Counter? {
        guard let commentCount = self.commentCount.value else { return nil }
        return .init(
            value: commentCount,
            leadingAction: .reply,
            trailingAction: nil
        )
    }
}
