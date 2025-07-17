//
//  PostUpdateQueue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

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
    
    private var queue: Queue<() async throws -> any PostSnapshotProviding> = .init()
    
    internal func setParent(_ newParent: any Post1Providing) {
//        print("DEBUG assigning parent \(newParent.id)")
//        if newParent is any Post3Providing {
//            print("DEBUG new parent is post3")
//        } else if newParent is any Post2Providing {
//            print("DEBUG new parent is post2")
//        } else {
//            print("DEBUG new parent is post1")
//        }
        // TODO: allow model to produce snapshot. Make lastVerifiedSnapshot always present; when parent is set, also set lastVerifiedSnapshot
        self.parent = newParent
    }
    
    internal func addItem(item: @escaping () async throws -> any PostSnapshotProviding) {
        queue.enqueue(item)
        if queue.numItems == 1 {
            Task {
                await executeQueue()
            }
        }
    }
    
    private func executeQueue() async {
        print("DEBUG executing queue")
        // assigning this here ensures parent stays in scope for the duration of the queue; for operations that remove the post
        // (e.g., hide), if the call is slow, the parent might go out of scope before it returns; this in turn breaks the undo behavior
        guard let parent else {
            assertionFailure("Cannot execute queue with no parent!")
            return
        }
        while let task = queue.next() {
            print("DEBUG found next task")
            do {
                let snapshot = try await task()
                lastVerifiedSnapshot = snapshot // TODO: only if rank high enough
                queue.dequeue()
            } catch {
                print(error)
            }
        }
        
        print("DEBUG done executing queue")
        if let lastVerifiedSnapshot {
            updateParent(parent, with: lastVerifiedSnapshot)
        }
    }
    
    private func updateParent(_ parent: any Post1Providing, with snapshot: any PostSnapshotProviding) {
        print("DEBUG updating parent")
//        guard let parent else {
//            assertionFailure("No parent")
//            return
//        }
        parent.snapshotUpdate(with: snapshot)
    }
}
