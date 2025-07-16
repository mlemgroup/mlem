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
    
    internal func updateParent(_ newParent: any Post1Providing) {
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
            updateParent(with: lastVerifiedSnapshot)
        }
    }
    
    private func updateParent(with snapshot: any PostSnapshotProviding) {
        print("DEBUG updating parent")
        guard let parent else {
            assertionFailure("No parent")
            return
        }
        parent.snapshotUpdate(with: snapshot)
    }
}
