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

extension UnifiedPostModel {
    var toggleVote: ((ScoringOperation) -> Void)? {
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
}
