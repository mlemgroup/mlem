//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

extension RegistrationApplication: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: RegistrationApplicationSnapshot, semaphore: UInt? = nil) {
        setIfChanged(\.questionResponse, snapshot.questionResponse)
        resolutionManager.updateWithReceivedValue(resolution, semaphore: semaphore)
        setIfChanged(\.resolver, api.caches.person.getOptionalModel(api: api, from: .person1(snapshot.resolver)))
        setIfChanged(\.email, snapshot.email)
        setIfChanged(\.emailVerified, snapshot.emailVerified)
        setIfChanged(\.showNsfw, snapshot.showNsfw)
        
        Task {
            await creator.updateQueue.attemptDirectUpdate(with: .init(api: api, snapshot: .person1(snapshot.creator)))
        }
    }
}
