//
//  UnifiedPostModel+Interactable.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-04.
//

import MlemMiddleware
import Haptics
import os

// TODO: NOW update Interactable1Providing to simple Interactable, conform Post etc.
// TODO: NOW make this file's scope more reasonable (not technically just interactable)

extension UnifiedPostModel: ShimVotable {
    public var toggleVote: ((ScoringOperation) -> Void)? {
        if let updateVote, let votes = votes.value {
            return { operation in
                updateVote(votes.myVote == operation ? .none : operation)
            }
        }
        return nil
    }
    
    var toggleDownvoted: ((Set<FeedbackType>) -> Void)? {
        if let updateVote, let votes = votes.value {
            return { feedback in
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .lightSuccess, tier: .low)
                }
                updateVote(votes.myVote == .downvote ? .none : .downvote)
            }
        }
        return nil
    }
    
    var toggleUpvoted: ((Set<FeedbackType>) -> Void)? {
        if let updateVote, let votes = votes.value {
            return { feedback in
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .lightSuccess, tier: .low)
                }
                updateVote(votes.myVote == .upvote ? .none : .upvote)
            }
        }
        return nil
    }
    
    var toggleSaved: ((Set<FeedbackType>) -> Void)? {
        if let saved = saved.value {
            return { feedback in
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .lightSuccess, tier: .low)
                }
                self.updateSaved(!saved)
            }
        }
        return nil
    }
    
    var toggleHidden: ((Set<FeedbackType>) -> Void)? {
        guard let hidden = hidden.value else { return nil }
        return { feedback in
            if feedback.contains(.haptic) {
                HapticManager.main.play(haptic: .lightSuccess, tier: .low)
            }
            if feedback.contains(.toast) {
                if hidden {
                    ToastModel.main.add(.success("Shown"))
                } else {
                    ToastModel.main.add(
                        .undoable(
                            "Hidden",
                            icon: .general.hide,
                            callback: { self.updateHidden(false) }
                        )
                    )
                }
            }
            self.updateHidden(!hidden)
        }
    }
    
    func toggleLocked(_ feedback: Set<FeedbackType>, callback: ((UpdateStatus) -> Void)? = nil) -> Void {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .lightSuccess, tier: .low)
        }
        updateLocked(!locked, callback: callback)
    }
    
    /// Toggles the community pinned status of this post
    /// - Parameter callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func togglePinnedCommunity(callback: ((UpdateStatus) -> Void)? = nil) {
        updatePinnedCommunity(!pinnedCommunity, callback: callback)
    }
    
    /// Toggles the instance pinned status of this post
    /// - Parameter callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func togglePinnedInstance(callback: ((UpdateStatus) -> Void)? = nil) {
        updatePinnedInstance(!pinnedInstance, callback: callback)
    }
}
