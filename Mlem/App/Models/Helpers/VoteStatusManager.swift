//
//  VoteStatusManager.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-03.
//

import Foundation

/// This class provides logic to ensure proper handling of returned voting calls so as to avoid flickering or the client falling out of sync.
/// `semaphore` is responsible for tracking who the most recent caller is. Every time a new vote is started, `semaphore` is incremented by one.
/// `cleanState` is responsible for tracking the last verified post state. If the current state of the post is in sync with the server, this will be nil.
/// When a vote begins, call `.beginVotingOperation` with the current vote state. If the post is clean, the `cleanState` is updated to match; otherwise the clean state is left untouched. The semaphore is incremented and its value returned.
/// When a vote finishes successfully, call `finishVotingOperation` with the new state returned from the server. If the caller is the most recent one, then clean state is wiped and a `true` value is returned; this indicates that the caller is clear to update the post with the returned value. If the caller is not the most recent one (i.e., another vote is underway), then the clean state is updated but a `false` value is returned; this indicates that the caller should not update the post with the returned value.
/// When a vote finishes unsuccessfully, call `getRollbackState`. If the caller is the most recent one, then the clean state is wiped and returned, and the caller should update the post with the returned state. If another vote is underway, the caller should do nothing and so `nil` is returned.
class VoteStatusManager {
    private var semaphore: Int = 0
    private var cleanState: VotesModel?
        
    /// Call at the start of a voting operation, BEFORE state faking is performed. Updates the clean state if nil and increments semaphore.
    /// - Returns: new sempaphore value
    func beginVotingOperation(with newState: VotesModel) -> Int {
        semaphore += 1
        print("DEBUG [\(semaphore)] began vote")
        if cleanState == nil {
            print("DEBUG [\(semaphore)] state is clean, updating")
            cleanState = newState
        }
        return semaphore
    }
    
    /// Call at the end of a successful voting operation. If the caller is the most recent caller, resets clean state and returns true; otherwise updates clean state and returns false.
    /// If this method returns false, the model SHOULD NOT be reinitialized with the result of a voting operation!
    func finishVotingOperation(semaphore: Int, with newState: VotesModel) -> Bool {
        if self.semaphore == semaphore {
            print("DEBUG [\(semaphore)] is the last caller! Resetting clean state")
            cleanState = nil
            return true
        }
        
        print("DEBUG [\(semaphore)] is not the last caller! Updating clean state")
        cleanState = newState
        return false
    }
    
    /// If the given semaphore is still the most recent operation, clears and returns the current clean state, if present; otherwise returns nil.
    func getRollbackState(semaphore: Int) -> VotesModel? {
        if self.semaphore == semaphore, let ret = cleanState {
            print("DEBUG [\(semaphore)] is the most recent caller! Resetting clean state.")
            cleanState = nil
            return ret
        }
        print("DEBUG [\(semaphore)] is not the most recent caller or vote state nil.")
        return nil
    }
}
