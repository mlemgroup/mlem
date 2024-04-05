//
//  InboxView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Foundation

extension InboxView {
    func refresh(tracker: InboxTracker) async {
        await tracker.refresh(clearBeforeFetch: false)
        
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
        commentReportTracker.unreadOnly = newShouldFilterRead
        postReportTracker.unreadOnly = newShouldFilterRead
        messageReportTracker.unreadOnly = newShouldFilterRead
        registrationApplicationTracker.unreadOnly = newShouldFilterRead
        
        if newShouldFilterRead {
            await personalInboxTracker.filterRead()
            
            // mod items are returned sorted by old when unreadOnly true
            await modOrAdminInboxTracker.changeSortType(to: .old)
        } else {
            await personalInboxTracker.refresh(clearBeforeFetch: true)
            await modOrAdminInboxTracker.changeSortType(to: .new)
        }
    }
    
    func markAllAsRead() async {
        // await inboxTracker.markAllAsRead(unreadTracker: unreadTracker)
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
