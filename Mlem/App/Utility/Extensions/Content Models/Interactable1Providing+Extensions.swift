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
    
    func showReplySheet(expandedPostTracker: ExpandedPostTracker? = nil) {
        if let self = self as? any Post2Providing {
            NavigationModel.main.openSheet(.reply(.post(self), expandedPostTracker: expandedPostTracker))
        } else {
            print("DEBUG showReplySheet: cannot open sheet!")
        }
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
            self2.toggleSaved()
            inboxItem?.updateRead(true)
        } else {
            print("DEBUG no self2 found in toggleSave!")
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
            trailingAction: downvoteAction(feedback: [.haptic])
        )
    }
    
    // MARK: Actions
    
    func upvoteAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = (self2?.votes.myVote ?? .none == .upvote)
        return .init(
            id: "upvote\(uid)",
            isOn: isOn,
            label: isOn ? "Undo Upvote" : "Upvote",
            color: Palette.main.upvote,
            icon: Icons.upvote,
            menuIcon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.upvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill,
            callback: api.canInteract ? { self.self2?.toggleUpvoted(feedback: feedback) } : nil
        )
    }
    
    func downvoteAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = (self2?.votes.myVote ?? .none == .downvote)
        return .init(
            id: "downvote\(uid)",
            isOn: isOn,
            label: isOn ? "Undo Downvote" : "Downvote",
            color: Palette.main.downvote,
            icon: Icons.downvote,
            menuIcon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.downvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill,
            callback: api.canInteract ? { self.self2?.toggleDownvoted(feedback: feedback) } : nil
        )
    }

    func saveAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        let isOn: Bool = self2?.saved ?? false
        return .init(
            id: "save\(uid)",
            isOn: isOn,
            label: isOn ? "Unsave" : "Save",
            color: Palette.main.save,
            icon: isOn ? Icons.saveFill : Icons.save,
            menuIcon: isOn ? Icons.saveFill : Icons.save,
            swipeIcon1: isOn ? Icons.unsave : Icons.save,
            swipeIcon2: isOn ? Icons.unsaveFill : Icons.saveFill,
            callback: api.canInteract ? { self.self2?.toggleSaved(feedback: feedback) } : nil
        )
    }
    
    func replyAction(expandedPostTracker: ExpandedPostTracker? = nil) -> BasicAction {
        .init(
            id: "reply\(uid)",
            isOn: false,
            label: "Reply",
            color: Palette.main.accent,
            icon: Icons.reply,
            menuIcon: Icons.reply,
            swipeIcon1: Icons.reply,
            swipeIcon2: Icons.replyFill,
            callback: api.canInteract ? { self.showReplySheet(expandedPostTracker: expandedPostTracker) } : nil
        )
    }
    
    func blockCreatorAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "blockCreator\(uid)",
            isOn: false,
            label: "Block User",
            color: Palette.main.negative,
            isDestructive: true,
            confirmationPrompt: showConfirmation ? "Really block this user?" : nil,
            icon: Icons.block,
            callback: api.canInteract ? { self.self2?.creator.toggleBlocked(feedback: feedback) } : nil
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
        .init(
            id: "comment\(uid)",
            label: self2?.commentCount.description,
            icon: Icons.replies
        )
    }
}
