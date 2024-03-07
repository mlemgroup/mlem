//
//  InboxView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Foundation

extension InboxView {
    func refresh() async {
        do {
            switch curTab {
            case .all:
                await inboxTracker.refresh(clearBeforeFetch: false)
            case .replies:
                try await replyTracker.refresh(clearBeforeRefresh: false)
            case .mentions:
                try await mentionTracker.refresh(clearBeforeRefresh: false)
            case .messages:
                try await messageTracker.refresh(clearBeforeRefresh: false)
            }
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func toggleFilterRead() {
        shouldFilterRead = !shouldFilterRead
    }
    
    func handleShouldFilterReadChange(newShouldFilterRead: Bool) async {
        replyTracker.unreadOnly = newShouldFilterRead
        mentionTracker.unreadOnly = newShouldFilterRead
        messageTracker.unreadOnly = newShouldFilterRead
        
        if newShouldFilterRead {
            await inboxTracker.filterRead()
        } else {
            await inboxTracker.refresh(clearBeforeFetch: true)
        }
    }
    
    func markAllAsRead() async {
        await inboxTracker.markAllAsRead(unreadTracker: unreadTracker)
    }
    
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        let (filterReadText, filterReadSymbol) = shouldFilterRead
            ? ("Show All", Icons.filterFill)
            : ("Show Only Unread", Icons.filter)
        
        ret.append(MenuFunction.standardMenuFunction(
            text: filterReadText,
            imageName: filterReadSymbol
        ) {
            toggleFilterRead()
        })
        
        ret.append(MenuFunction.standardMenuFunction(
            text: "Mark All as Read",
            imageName: "envelope.open"
        ) {
            Task(priority: .userInitiated) {
                await markAllAsRead()
            }
        })
        
        return ret
    }
}
