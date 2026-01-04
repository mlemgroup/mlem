//
//  UnifiedPostModel+Interactable.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-04.
//

import MlemMiddleware
import Haptics

// TODO: NOW update Interactable1Providing to simple Interactable, conform Post etc.

extension UnifiedPostModel {
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
        if let updateSaved, let saved = saved.value {
            return { feedback in
                if feedback.contains(.haptic) {
                    HapticManager.main.play(haptic: .lightSuccess, tier: .low)
                }
                updateSaved(!saved)
            }
        }
        return nil
    }
}
