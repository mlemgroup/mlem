//
//  InteractableProviding+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-24.
//

import Icons
import MlemMiddleware
import Theming
import os

// Methods to support actions

extension InteractableProviding {
        
    // MARK: Readouts
    
    var createdReadout: Readout {
        .init(
            id: "created\(uid)",
            label: (updated ?? created).getShortRelativeTime(),
            icon: updated == nil ? .general.time : .general.updateTime
        )
    }
    
    func scoreReadout(showColor: Bool) -> Readout? {
        guard let votes = votes.value else { return nil }
        let icon: Icon
        let color: ThemedColor?
        switch votes.myVote {
        case .upvote:
            icon = .lemmy.upvoted.representingState(active: true)
            color = .themedUpvote
        case .downvote:
            icon = .lemmy.downvoted.representingState(active: true)
            color = .themedDownvote
        default:
            icon = .lemmy.upvoted.representingState(active: false)
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
            icon: .lemmy.upvoted.representingState(active: isOn),
            color: isOn && showColor ? .themedUpvote : nil
        )
    }
    
    func downvoteReadout(showColor: Bool) -> Readout? {
        guard let votes = votes.value else { return nil }
        let isOn = votes.myVote == .downvote
        return Readout(
            id: "downvote\(uid)",
            label: votes.downvotes.description,
            icon: .lemmy.downvoted.representingState(active: isOn),
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
            icon: .lemmy.comment,
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
            icon: .lemmy.saved.representingState(active: isOn),
            color: isOn && showColor ? .themedSave : nil
        )
    }
    
    // MARK: Counters
    
    func upvoteCounter(appState: AppState) -> Counter? {
        guard let votes = votes.value else { return nil }
        return .init(
            value: votes.upvotes,
            leadingAction: .upvote,
            trailingAction: nil
        )
    }
    
    func downvoteCounter(appState: AppState, downvotesEnabled: Bool) -> Counter? {
        guard let votes = votes.value else { return nil }
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
        guard let votes = votes.value else { return nil }
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
