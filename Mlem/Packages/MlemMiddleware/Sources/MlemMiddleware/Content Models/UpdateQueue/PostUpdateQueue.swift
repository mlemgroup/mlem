//
//  PostUpdateQueue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

import Semaphore

/// This actor synchronizes state updates for a particular post.
///
/// Calls are queued using `addItem`, and each call must return a `PostSnapshotProviding`. When each call returns, `lastVerifiedSnapshot` is updated
/// with the returned snapshot. Each call will only execute when the previous one finishes, ensuring that `lastVerifiedSnapshot` always accurately reflects
/// the most recently queried server state.
///
/// When the queue finishes executing altogether, it updates its parent model with the most recent snapshot. State faking is performed by the model
/// before the work item is queued.
///
/// - Note: some care must be taken to ensure that `parent` always points to a valid model. When a model is initialized, it updates `parent` to be itself;
/// likewise, when a model is deinitialized, it updates `parent` to be the next lower-tier model contained within itself (e.g., `Post3`'s deinit updates parent
/// to be `post2`). If this update is not performed, `parent` may become nil and the queue will refuse to execute. In debug mode this will throw an error,
/// while in production the queue will simply not run until an item is added when the parent is present.
public actor PostUpdateQueue {
    weak var parent: (any Post1Providing)?
    
    private var lastVerifiedSnapshot: (any PostSnapshotProviding)?
    
    private var semaphore: AsyncSemaphore = .init(value: 1)
    private var queue: Queue<PostUpdateTask> = .init()

    internal func setParent(_ newParent: any Post1Providing) {
        self.parent = newParent
        // this ensures that if we set a parent to a higher tier model, lastVerifiedSnapshot is upgraded to that tier as well
        let parentSnapshot = newParent.takeSnapshot()
        self.lastVerifiedSnapshot = self.lastVerifiedSnapshot?.merge(with: parentSnapshot) ?? parentSnapshot
    }
    
    /// Add a task to the queue for a repository call that returns a complete snapshot.
    /// - Note: prefer this method over the snapshot-modifying variant below
    internal func addItem(item: @escaping () async throws -> any PostSnapshotProviding) {
        addItem(.createsSnapshot(item))
    }
    
    /// Add a task to the queue for a repository call that **does not** return a complete snapshot. The queue will provide the latest verified
    /// snapshot to the task, which should then modify and return the snapshot according to the repository call result.
    /// - Note: **only** use this method when absolutely necessary; if the repository returns a complete snapshot, use the variant above.
    internal func addItem(item: @escaping (any PostSnapshotProviding) async throws -> any PostSnapshotProviding) {
        addItem(.modifiesSnapshot(item))
    }
    
    /// Queues the given upgrade operation for execution
    /// - Returns: post returned by the upgrade operation
    /// - Warning: this method assumes that the given operation will update this queue's parent (this generally happens in the parent's initializer)
    internal func addUpgrade(task: @escaping () async throws -> (Post3Snapshot, Post3)) async throws -> any Post {
        // this method is a unique case because the context it is called from needs to receive its result. This method therefore waits
        // for any currently queued actions to finish, then blocks the queue from restarting until the upgrade is complete.
        await semaphore.wait()
        defer {
            semaphore.signal()
            print("DEBUG upgrade complete")
        }
        print("DEBUG beginning upgrade")
        
        let (snapshot, post) = try await task()
        lastVerifiedSnapshot = snapshot
        return post
    }
    
    private func addItem(_ item: PostUpdateTask) {
        queue.enqueue(item)
        if queue.numItems == 1 {
            Task {
                await executeQueue()
            }
        }
    }
    
    private func executeQueue() async {
        await semaphore.wait()
        defer {
            semaphore.signal()
            print("DEBUG finished executing queue")
        }
        print("DEBUG executing queue")
        
        // assigning this here ensures parent stays in scope for the duration of the queue. For operations that remove the post
        // (e.g., hide), if the call is slow, the parent might go out of scope before it returns; this in turn breaks the undo behavior
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
                let snapshot: any PostSnapshotProviding
                switch task {
                case let .createsSnapshot(callback):
                    snapshot = try await callback()
                case let .modifiesSnapshot(callback):
                    snapshot = try await callback(lastVerifiedSnapshot)
                }
                
                // in case the function returned a lower tier snapshot than currently available, merge lastVerifiedSnapshot into the returned
                // snapshot. This operation prefers the returned snapshot, so if it is of equal or higher tier than lastVerifiedSnapshot,
                // it overrides it entirely
                let newSnapshot = snapshot.merge(with: lastVerifiedSnapshot)
                self.lastVerifiedSnapshot = newSnapshot
                lastVerifiedSnapshot = newSnapshot // also need to update scoped lastVerifiedSnapshot so updateParent gets the correct value
                queue.dequeue()
            } catch {
                print(error)
            }
        }
        
        await updateParent(parent, with: lastVerifiedSnapshot)
    }
    
    private func updateParent(_ parent: any Post1Providing, with snapshot: any PostSnapshotProviding) async {
        print("DEBUG updating parent")
        await parent.snapshotUpdate(with: snapshot)
    }
}

enum PostUpdateTask {
    case createsSnapshot(() async throws -> any PostSnapshotProviding)
    case modifiesSnapshot((any PostSnapshotProviding) async throws -> any PostSnapshotProviding)
}
