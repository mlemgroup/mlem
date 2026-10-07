//
//  Post+Toggles.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-04.
//

import MlemMiddleware
import Haptics
import os
import Foundation

// Convenience methods for toggling statuses with feedback

extension Post {
    var toggleHidden: (() -> Void)? {
        guard let hidden = hidden.value else { return nil }
        return {
            self.updateHidden(!hidden)
        }
    }

    func toggleLocked(callback: ((UpdateStatus) -> Void)? = nil) {
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
    
    func toggleNsfw(callback: ((UpdateStatus) -> Void)?) {
        updateNsfw(!nsfw, callback: callback)
    }
    
    // MARK: - Helpers
    
    // TODO: UpdateQueue remove this shim code
    internal func handleModerationActionCompletion(
        message: LocalizedStringResource,
        result: UpdateStatus,
        feedback: Set<FeedbackType>
    ) async {
        var stateUpdateResult: StateUpdateResult
        switch result {
        case .success:
            stateUpdateResult = .succeeded
        case .failure:
            stateUpdateResult = .failed
        }
        await handleModerationActionCompletion(message: message, result: stateUpdateResult, feedback: feedback)
    }
    
    internal func handleModerationActionCompletion(
        message: LocalizedStringResource,
        result: StateUpdateResult,
        feedback: Set<FeedbackType>
    ) async {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .success, tier: .low)
        }
        switch result {
        case .failed:
            ToastModel.main.add(.failure(message))
        default:
            break
        }
    }
}
