//
//  PostUpdateQueue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

internal actor PostUpdateQueue {
    weak var parent: (any PostStubProviding)?
    
    private var lastVerifiedSnapshot: (any PostSnapshotProviding)?
    
    private var queue: Queue<() async throws -> any PostSnapshotProviding> = .init()
    
    private func executeQueue() async {
        while let task = queue.next() {
            do {
                let snapshot = try await task()
                lastVerifiedSnapshot = snapshot // TODO: only if rank high enough
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
