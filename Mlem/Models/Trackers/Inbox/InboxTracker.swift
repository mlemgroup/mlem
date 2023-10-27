//
//  InboxTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-26.
//

import Dependencies
import Foundation

class InboxTracker: ParentTracker<InboxItem> {
    @Dependency(\.inboxRepository) var inboxRepository
    @Dependency(\.hapticManager) var hapticManager
    
    func filterRead() async {
        await filter { item in
            !item.read
        }
    }
    
    func markAllAsRead(unreadTracker: UnreadTracker) async {
        do {
            try await inboxRepository.markAllAsRead()
            await unreadTracker.reset()
            // TODO: state fake read for everything? I don't love the clearBeforeFetch here but it's better than the long wait with no indicator
            await refresh(clearBeforeFetch: true)
        } catch {
            errorHandler.handle(error)
            hapticManager.play(haptic: .failure, priority: .high)
        }
    }
    
    // this function isn't actually used right now because there isn't a nice way to filter blocked users on refresh, but it'll be useful some day
    func filterUser(id: Int) async {
        await filter { item in
            item.creatorId != id
        }
    }
}
