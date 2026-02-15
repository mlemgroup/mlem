//
//  Report.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

extension Report {
    public var cacheId: Int {
        var hasher = Hasher()
        hasher.combine(target.type)
        hasher.combine(id)
        return hasher.finalize()
    }
    
    @MainActor
    func update(with snapshot: ReportSnapshot, semaphore: UInt? = nil) {
        setIfChanged(\.updated, snapshot.updated)
        setIfChanged(\.reason, snapshot.reason)
        setIfChanged(\.resolver, api.caches.person.getOptionalModel(api: api, from: .person1(snapshot.resolver)))
        resolvedManager.updateWithReceivedValue(snapshot.resolved, semaphore: semaphore)
        
        target.update(with: snapshot.target)
        
        Task {
            await creator.updateQueue.attemptDirectUpdate(with: .init(api: api, snapshot: .person1(snapshot.creator)))
        }
    }
}
