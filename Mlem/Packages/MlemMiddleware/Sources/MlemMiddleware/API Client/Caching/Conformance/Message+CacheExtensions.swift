//
//  Message+CacheExtensions.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

extension Message1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Message1Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.content, snapshot.content)
        setIfChanged(\.updated, snapshot.updated)
        
        deletedManager.updateWithReceivedValue(snapshot.deleted, semaphore: semaphore)
    }
}

extension Message2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Message2Snapshot, semaphore: UInt? = nil) {
        message1.update(with: snapshot.message, semaphore: semaphore)
        creator.update(with: snapshot.creator, semaphore: semaphore)
        recipient.update(with: snapshot.recipient, semaphore: semaphore)
    }
}
