//
//  InteractableProviding+Toggles.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import Haptics
import MlemMiddleware
import SwiftUI
import Theming

// Convenience methods for toggling statuses with feedback

extension InteractableProviding {
    private var inboxItem: (any InboxItemProviding)? { self as? any InboxItemProviding }
    
    var toggleUpvoted: ((Set<FeedbackType>) -> Void)? {
        if let updateVote, let votes = votes.value {
            return { feedback in
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .lightSuccess, tier: .low)
                }
                updateVote(votes.myVote == .upvote ? .none : .upvote)
                self.inboxItem?.updateRead(true)
            }
        }
        return nil
    }
    
//    func toggleUpvoted(feedback: Set<FeedbackType>) {
//        guard let toggleUpvoted else {
//            handleError(MlemError.modelError("No self2 found"), silent: true)
//            return
//        }
//        if feedback.contains(.haptic) {
//            HapticManager.main.play(haptic: .lightSuccess, tier: .low)
//        }
//        toggleUpvoted()
//        inboxItem?.updateRead(true)
//    }
    
    var toggleDownvoted: ((Set<FeedbackType>) -> Void)? {
        if let updateVote, let votes = votes.value {
            return { feedback in
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .lightSuccess, tier: .low)
                }
                updateVote(votes.myVote == .downvote ? .none : .downvote)
                self.inboxItem?.updateRead(true)
            }
        }
        return nil
    }
    
//    func toggleDownvoted(feedback: Set<FeedbackType>) {
//        guard let toggleDownvoted else {
//            handleError(MlemError.modelError("No self2 found"), silent: true)
//            return
//        }
//        if feedback.contains(.haptic) {
//            HapticManager.main.play(haptic: .lightSuccess, tier: .low)
//        }
//        toggleDownvoted()
//        inboxItem?.updateRead(true)
//    }
    
    var toggleSaved: ((Set<FeedbackType>) -> Void)? {
        if let saved = saved.value,
           let votes = votes.value,
           let updateVote {
            return { feedback in
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .lightSuccess, tier: .low)
                }
                
                @Setting(\.behavior_upvoteOnSave) var upvoteOnSave
                if upvoteOnSave, !saved, votes.myVote != .upvote {
                    updateVote(.upvote)
                }
                self.updateSaved(!saved)
            }
        }
        return nil
    }
    
//    func toggleSaved(feedback: Set<FeedbackType>) {
//        guard let saved = saved.value,
//              let votes = votes.value,
//              let updateVote,
//              let toggleSaved else {
//            handleError(MlemError.modelError("No self2 found"), silent: true)
//            return
//        }
//        if feedback.contains(.haptic) {
//            HapticManager.main.play(haptic: .success, tier: .low)
//        }
//        @Setting(\.behavior_upvoteOnSave) var upvoteOnSave
//        if upvoteOnSave, !saved, votes.myVote != .upvote {
//            updateVote(.upvote)
//        }
//        
//        toggleSaved()
//        inboxItem?.updateRead(true)
//    }
    
    func toggleRemoved(reason: String?, feedback: Set<FeedbackType>) {
        let initialValue = removed
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .success, tier: .low)
        }
        toggleRemoved(reason: reason) { status in
            if case .failure = status {
                ToastModel.main.add(.failure(initialValue ? "Failed to remove content" : "Failed to restore content"))
            }
        }
    }
}
