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
    func update(with message: ApiPrivateMessage, semaphore: UInt? = nil) {
        setIfChanged(\.content, message.content)
        setIfChanged(\.updated, message.updated)
        
        deletedManager.updateWithReceivedValue(message.deleted, semaphore: semaphore)
        if !isOwnMessage {
            readManager.updateWithReceivedValue(message.read, semaphore: semaphore)
        }
    }
}

extension Message2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with message: ApiPrivateMessageView, semaphore: UInt? = nil) {
        message1.update(with: message.privateMessage, semaphore: semaphore)
        creator.update(with: message.creator, semaphore: semaphore)
        recipient.update(with: message.recipient, semaphore: semaphore)
    }
}
