//
//  InboxNotificationUpdateQueue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

import Semaphore

/// This actor synchronizes state updates for a particular inbox notification.
///
/// Calls are queued using `addItem`, and each call must return an `InboxNotificationSnapshot`. When each call returns, `lastVerifiedSnapshot` is updated
/// with the returned snapshot. Each call will only execute when the previous one finishes, ensuring that `lastVerifiedSnapshot` always accurately reflects
/// the most recently queried server state.
///
/// When the queue finishes executing altogether, it updates its parent model with the most recent snapshot. State faking is performed by the model
/// before the work item is queued.
///
public actor InboxNotificationUpdateQueue {
    weak var parent: InboxNotification?
    
    private var lastVerifiedSnapshot: InboxNotificationSnapshot?
    
    private var semaphore: AsyncSemaphore = .init(value: 1)
    private var queue: Queue<InboxNotificationUpdateTask> = .init()

    func setParent(_ newParent: InboxNotification) {
        parent = newParent
        lastVerifiedSnapshot = newParent.takeSnapshot()
    }
    
    /// Add a task to the queue for a repository call that returns a complete snapshot.
    /// - Note: prefer this method over the snapshot-modifying variant below
    func addItem(item: @escaping () async throws -> InboxNotificationSnapshot) {
        addItem(.createsSnapshot(item))
    }
    
    /// Add a task to the queue for a repository call that **does not** return a complete snapshot. The queue will provide the latest verified
    /// snapshot to the task, which should then modify and return the snapshot according to the repository call result.
    /// - Note: **only** use this method when absolutely necessary; if the repository returns a complete snapshot, use the variant above.
    func addItem(item: @escaping (InboxNotificationSnapshot) async throws -> InboxNotificationSnapshot) {
        addItem(.modifiesSnapshot(item))
    }
    
    private func addItem(_ item: InboxNotificationUpdateTask) {
        queue.enqueue(item)
        if queue.numItems == 1 {
            Task {
                await executeQueue()
            }
        }
    }
    
    /// Attempts to update the notification with the given snapshot. If any tasks are queued, no action will be taken.
    /// This method should be called when new snapshots are received by actions in a foreign object's queue or by headless calls
    func attemptDirectUpdate(with snapshot: InboxNotificationSnapshot) async {
        guard queue.numItems == 0, let parent else { return }
        await updateParent(parent, with: snapshot)
    }
    
    private func executeQueue() async {
        await semaphore.wait()
        defer {
            semaphore.signal()
            print("DEBUG finished executing queue")
        }
        print("DEBUG executing queue")
        
        guard let parent else {
            assertionFailure("Cannot execute queue with no parent!")
            return
        }
        // this shouldn't be possible, since lastVerifiedSnapshot is set when the parent is set
        guard var lastVerifiedSnapshot else {
            assertionFailure("Cannot execute queue with no lastVerifiedSnapshot!")
            return
        }
        while let task = queue.next() {
            print("DEBUG found next task")
            do {
                let snapshot: InboxNotificationSnapshot
                switch task {
                case let .createsSnapshot(callback):
                    snapshot = try await callback()
                case let .modifiesSnapshot(callback):
                    snapshot = try await callback(lastVerifiedSnapshot)
                }
                
                self.lastVerifiedSnapshot = snapshot
                lastVerifiedSnapshot = snapshot // also need to update scoped lastVerifiedSnapshot so updateParent gets the correct value\
            } catch {
                print(error)
            }
            queue.dequeue()
        }
        
        await updateParent(parent, with: lastVerifiedSnapshot)
    }
    
    private func updateParent(_ parent: InboxNotification, with snapshot: InboxNotificationSnapshot) async {
        await parent.snapshotUpdate(with: snapshot)
    }
}

enum InboxNotificationUpdateTask {
    case createsSnapshot(() async throws -> InboxNotificationSnapshot)
    case modifiesSnapshot((InboxNotificationSnapshot) async throws -> InboxNotificationSnapshot)
}
