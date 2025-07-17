//
//  PostUpdateQueue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

public actor PostUpdateQueue {
    weak var parent: (any Post1Providing)?
    
    private var lastVerifiedSnapshot: (any PostSnapshotProviding)?
    
    private var queue: Queue<() async throws -> any PostSnapshotProviding> = .init()
    
    internal func setParent(_ newParent: any Post1Providing) {
        print("DEBUG assigning parent \(newParent.id)")
        if newParent is any Post3Providing {
            print("DEBUG new parent is post3")
        } else if newParent is any Post2Providing {
            print("DEBUG new parent is post2")
        } else if newParent is any Post1Providing {
            print("DEBUG new parent is post1")
        }
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
