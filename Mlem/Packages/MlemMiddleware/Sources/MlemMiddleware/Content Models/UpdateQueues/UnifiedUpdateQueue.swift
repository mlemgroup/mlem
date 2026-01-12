//
//  UnifiedUpdateQueue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-12-27.
//

import os
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
public actor UnifiedUpdateQueue<Model: UnifiedModelProviding> {
    let log: Logger = .mlemLogger()
    
    let parent: Model
    
    private var lastVerifiedProperties: Model.Properties
    private var upgradeQueued: Bool = false
    
    private var semaphore: AsyncSemaphore = .init(value: 1)
    private var queue: Queue<UpdateTask> = .init()
    
    init(parent: Model) {
        self.parent = parent
        self.lastVerifiedProperties = parent.properties
    }
    
    func upgrade() async throws {
        // this method is a unique case because upgrade will be called at every property access on the parent model until
        // the required properties are provided. Therefore we block all upgrade calls once one is queued.
        guard !upgradeQueued else {
            return
        }
        upgradeQueued = true
        
        addItem {
            defer { self.upgradeQueued = false }
            return try await self.parent.fetchUpgraded()
        }
    }
    
    /// Add a task to the queue for a repository call that returns a complete snapshot.
    /// - Note: prefer this method over the snapshot-modifying variant below
    func addItem(item: @escaping () async throws -> Model.Properties) {
        addItem(.createsProperties(item))
    }
    
    /// Add a task to the queue for a repository call that **does not** return a complete snapshot. The queue will provide the latest verified
    /// snapshot to the task, which should then modify and return the snapshot according to the repository call result.
    /// - Note: **only** use this method when absolutely necessary; if the repository returns a complete snapshot, use the variant above.
    func addItem(item: @escaping (Model.Properties) async throws -> Model.Properties) {
        addItem(.modifiesProperties(item))
    }
    
    /// Attempts to update the post with the given snapshot. If any tasks are queued, no action will be taken.
    /// This method should be called when new snapshots are received by actions in a foreign object's queue or by headless calls
    func attemptDirectUpdate(with properties: Model.Properties) async {
        guard queue.numItems == 0 else { return }
        await updateParent(parent, with: properties)
    }
    
    private func addItem(_ item: UpdateTask) {
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
            log.debug("Finished executing queue")
        }
        log.info("Executing queue")
        
        while let task = queue.next() {
            log.debug("Found next task")
            do {
                let newProperties: Model.Properties
                switch task {
                case let .createsProperties(callback):
                    newProperties = try await callback()
                case let .modifiesProperties(callback):
                    newProperties = try await callback(lastVerifiedProperties)
                }
                
                // TODO: NOW merge
                self.lastVerifiedProperties = newProperties
            } catch {
                log.error("\(error.localizedDescription)")
            }
            queue.dequeue()
        }
        
        await updateParent(parent, with: lastVerifiedProperties)
    }
    
    @MainActor
    private func updateParent(_ parent: Model, with properties: Model.Properties) {
         // parent must be passed in rather than accessed directly due to actor access constraints
        parent.properties.update(with: properties)
    }
    
    enum UpdateTask {
        case createsProperties(() async throws -> Model.Properties)
        case modifiesProperties((Model.Properties) async throws -> Model.Properties)
    }
}
