//
//  PostUpdateQueue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

internal actor PostUpdateQueue {
    weak var parent: (any PostStubProviding & AnyObject)?
    
    private var lastVerifiedSnapshot: (any PostSnapshotProviding)?
    
    private var queue: Queue<() async throws -> any PostSnapshotProviding> = .init()
    
    internal func addItem(item: @escaping () async throws -> any PostSnapshotProviding) {
        queue.enqueue(item)
        if queue.numItems == 1 {
            Task {
                await executeQueue()
            }
        }
    }
    
    private func executeQueue() async {
        while let task = queue.next() {
            do {
                let snapshot = try await task()
                lastVerifiedSnapshot = snapshot // TODO: only if rank high enough
                queue.dequeue()
            } catch {
                print(error)
            }
        }
        
        if let lastVerifiedSnapshot {
            updateParent(with: lastVerifiedSnapshot)
        }
    }
    
    private func updateParent(with snapshot: any PostSnapshotProviding) {
        print("Updating parent")
    }
}
