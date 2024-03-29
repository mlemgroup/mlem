//
//  StateManager.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-03.
//

import Foundation

// These can't go inside of StateManager because generic classes cannot store static properties
private class SemaphoreServer {
    static var value: UInt = 0
    
    static func next() -> UInt {
        value += 1
        return value
    }
}

/// This class provides logic to ensure proper handling of returned API responses so as to avoid flickering or the client falling out of sync.
/// When you begin a task, call `.beginVotingOperation` with the result you expect to get. If no other operations are ongoing, `lastVerifiedValue` is updated to match; otherwise `lastVerifiedValue` is left untouched. The semaphore is incremented and its value returned.
/// When a vote finishes successfully, call `finishVotingOperation` with the new state returned from the server. If the caller is the most recent one, then clean state is wiped and a `true` value is returned; this indicates that the caller is clear to update the post with the returned value. If the caller is not the most recent one (i.e., another vote is underway), then the clean state is updated but a `false` value is returned; this indicates that the caller should not update the post with the returned value.
/// When a vote finishes unsuccessfully, call `rollback`. If the caller is the most recent one, then the  `wrappedValue` will be reset to the `lastVerifiedValue`.
class StateManager<Value: Any> {
    /// The state-faked value that should be shown to the user.
    private(set) var wrappedValue: Value
    
    /// Responsible for tracking who the most recent caller is. Every time the state is changed, `semaphore` is incremented by one.
    private var semaphore: UInt = 0
    
    /// Responsible for tracking the last verified value. If the current value is in sync with the server, this will be nil.
    private var lastVerifiedValue: Value?
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
        
    /// Call at the start of a voting operation, BEFORE state faking is performed. Updates the clean state if nil and increments semaphore.
    /// - Returns: new sempaphore value
    func beginOperation(expectedResult: Value, semaphore: UInt? = nil) -> UInt {
        self.semaphore = semaphore ?? SemaphoreServer.next()
        print("DEBUG [\(self.semaphore)] began operation.")
        if lastVerifiedValue == nil {
            print("DEBUG [\(self.semaphore)] Set lastVerifiedValue.")
            lastVerifiedValue = wrappedValue
        }
        DispatchQueue.main.async {
            self.wrappedValue = expectedResult
        }
        return self.semaphore
    }
    
    /// Call at the end of a successful voting operation. If the caller is the most recent caller, resets clean state and returns true; otherwise updates clean state and returns false.
    /// If this method returns false, the model SHOULD NOT be reinitialized with the result of a voting operation!
    @discardableResult
    func updateWithReceivedValue(_ newState: Value, semaphore: UInt?) -> Bool {
        if self.semaphore == semaphore {
            print("DEBUG [\(semaphore?.description ?? "nil")] is the last caller! Resetting lastVerifiedValue.")
            lastVerifiedValue = nil
            return true
        }
        
        print("DEBUG [\(semaphore?.description ?? "nil")] is not the last caller! Updating lastVerifiedValue.")
        lastVerifiedValue = newState
        return false
    }
    
    /// If the given semaphore is still the most recent operation, rollback `wrappedValue` to `cleanValue`.
    func rollback(semaphore: UInt) {
        if self.semaphore == semaphore, let lastVerifiedValue {
            print("DEBUG [\(semaphore)] is the most recent caller! Resetting lastVerifiedValue.")
            self.wrappedValue = lastVerifiedValue
            self.lastVerifiedValue = nil
        } else {
            print("DEBUG [\(semaphore)] is not the most recent caller or vote state nil.")
        }
    }
    
    func performRequest(expectedResult: Value, operation: @escaping (_ semaphore: UInt) async throws -> Void) {
        let semaphore = self.beginOperation(expectedResult: expectedResult)
        Task {
            do {
                try await operation(semaphore)
            } catch {
                print("DEBUG [\(semaphore)] failed!")
                self.rollback(semaphore: semaphore)
            }
        }
    }
}
