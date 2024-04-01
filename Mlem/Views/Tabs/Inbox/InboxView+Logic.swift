//
//  InboxView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Foundation

extension InboxView {
    func refresh() async {
        await inboxTracker.refresh(clearBeforeFetch: false)
        await personalInboxTracker.refresh(clearBeforeFetch: false)
        await modInboxTracker.refresh(clearBeforeFetch: false)
        
        do {
            let unreadCounts = try await personRepository.getUnreadCounts()
            unreadTracker.update(with: unreadCounts)
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
    
    func genFeedSwitchingFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        availableFeeds.forEach { type in
            let (imageName, enabled) = type != selectedInbox
                ? (type.iconName, true)
                : (type.iconNameFill, false)
            ret.append(MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                enabled: enabled
            ) {
                selectedInbox = type
            }
            )
        }
        return ret
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
