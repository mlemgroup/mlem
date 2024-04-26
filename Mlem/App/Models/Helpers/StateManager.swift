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

protocol StateManagerTickerProtocol {
    var valid: Bool { get }
    func begin(semaphore: UInt)
    func rollback(semaphore: UInt)
}

struct StateManagerTicket<Value: Equatable>: StateManagerTickerProtocol {
    let manager: StateManager<Value>
    let expectedResult: Value
    
    func begin(semaphore: UInt) {
        manager.beginOperation(expectedResult: expectedResult, semaphore: semaphore)
    }
    
    func rollback(semaphore: UInt) {
        manager.rollback(semaphore: semaphore)
    }
    
    var valid: Bool {
        manager.wrappedValue != expectedResult
    }
}

/// This class provides logic to ensure proper handling of returned API responses so as to avoid flickering or the client falling out of sync.
/// When you begin a task, call `.beginVotingOperation` with the result you expect to get. If no other operations are ongoing, `lastVerifiedValue` is updated to match; otherwise `lastVerifiedValue` is left untouched. The semaphore is incremented and its value returned.
/// When a vote finishes successfully, call `finishVotingOperation` with the new state returned from the server. If the caller is the most recent one, then clean state is wiped and a `true` value is returned; this indicates that the caller is clear to update the post with the returned value. If the caller is not the most recent one (i.e., another vote is underway), then the clean state is updated but a `false` value is returned; this indicates that the caller should not update the post with the returned value.
/// When a vote finishes unsuccessfully, call `rollback`. If the caller is the most recent one, then the  `wrappedValue` will be reset to the `lastVerifiedValue`.
@Observable
class StateManager<Value: Equatable> {
    /// The state-faked value that should be shown to the user.
    private(set) var wrappedValue: Value
    
    /// Responsible for tracking who the most recent caller is. Every time the state is changed, `lastSemaphore` is incremented by one.
    private var lastSemaphore: UInt = 0
    
    /// Responsible for tracking the last verified value. If the current value is in sync with the server, this will be nil.
    private var lastVerifiedValue: Value?
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
        
    /// Call at the start of a voting operation, BEFORE state faking is performed. Updates the clean state if nil and increments semaphore.
    /// - Returns: new sempaphore value
    @discardableResult
    func beginOperation(expectedResult: Value, semaphore: UInt? = nil) -> UInt {
        lastSemaphore = semaphore ?? SemaphoreServer.next()
        print("DEBUG [\(lastSemaphore)] began operation.")
        if lastVerifiedValue == nil {
            print("DEBUG [\(lastSemaphore)] Set lastVerifiedValue to \(wrappedValue).")
            lastVerifiedValue = wrappedValue
        }
        DispatchQueue.main.async {
            self.wrappedValue = expectedResult
        }
        return lastSemaphore
    }
    
    /// Call at the end of a successful operation. If the caller is the most recent caller, resets clean state and returns true; otherwise updates clean state and returns false.
    /// If this method returns false, the model SHOULD NOT be reinitialized with the result of a voting operation!
    @discardableResult
    func updateWithReceivedValue(_ newState: Value, semaphore: UInt?) -> Bool {
        if lastVerifiedValue == nil {
            wrappedValue = newState
            return false
        }
        
        if lastSemaphore == semaphore {
            print("DEBUG [\(semaphore?.description ?? "nil")] is the last caller! Resetting lastVerifiedValue.")
            lastVerifiedValue = nil
            return true
        }
        
        if lastVerifiedValue != newState {
            lastVerifiedValue = newState
            if semaphore != nil {
                print("DEBUG [\(semaphore?.description ?? "nil")] is not the last caller! Updating lastVerifiedValue to \(wrappedValue).")
            }
        }
        return false
    }
    
    /// If the given semaphore is still the most recent operation, rollback `wrappedValue` to `cleanValue`.
    func rollback(semaphore: UInt) {
        if lastSemaphore == semaphore, let lastVerifiedValue {
            print("DEBUG [\(semaphore)] is the most recent caller! Resetting lastVerifiedValue.")
            wrappedValue = lastVerifiedValue
            self.lastVerifiedValue = nil
        } else {
            print("DEBUG [\(semaphore)] is not the most recent caller or vote state nil.")
        }
    }
    
    func performRequest(
        expectedResult: Value,
        operation: @escaping (_ semaphore: UInt) async throws -> Void
    ) {
        guard wrappedValue != expectedResult else { return }
        let semaphore = beginOperation(expectedResult: expectedResult)
        Task {
            do {
                try await operation(semaphore)
            } catch {
                print("DEBUG [\(semaphore)] failed!")
                self.rollback(semaphore: semaphore)
            }
        }
    }
    
    func ticket(_ expectedResult: Value) -> StateManagerTicket<Value> {
        StateManagerTicket(manager: self, expectedResult: expectedResult)
    }
}

func groupStateRequest(
    _ tickets: [any StateManagerTickerProtocol],
    operation: @escaping (_ semaphore: UInt) async throws -> Void
) {
    let semaphore = SemaphoreServer.next()
    
    let tickets = tickets.filter(\.valid)
    
    for ticket in tickets {
        ticket.begin(semaphore: semaphore)
    }
    Task {
        do {
            try await operation(semaphore)
        } catch {
            for ticket in tickets {
                ticket.rollback(semaphore: semaphore)
            }
        }
    }
}

func groupStateRequest(
    _ tickets: (any StateManagerTickerProtocol)...,
    operation: @escaping (_ semaphore: UInt) async throws -> Void
) {
    groupStateRequest(tickets, operation: operation)
}
