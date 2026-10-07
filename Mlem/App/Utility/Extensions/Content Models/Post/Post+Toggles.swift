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
}
