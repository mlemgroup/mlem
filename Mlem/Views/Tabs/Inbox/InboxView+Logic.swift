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
        await unreadTracker.update()
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
        await personalInboxTracker.markAllAsRead(unreadTracker: unreadTracker)
    }
    
    func genFeedSwitchingFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        availableFeeds.forEach { type in
            let (imageName, enabled) = type != selectedInbox
                ? (type.iconName, true)
                : (type.iconNameFill, false)
            let label = type.enrichedLabel(
                unread: type == .personal ? unreadTracker.personal : unreadTracker.modAndAdmin
            )
            ret.append(MenuFunction.standardMenuFunction(
                text: label,
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
    
    func tabValue(for tab: InboxTab) -> Int {
        switch tab {
        case .all:
            switch selectedInbox {
            case .personal:
                unreadTracker.personal
            case .mod:
                unreadTracker.modAndAdmin
            }
        case .replies: unreadTracker.replies.count
        case .mentions: unreadTracker.mentions.count
        case .messages: unreadTracker.messages.count
        case .commentReports: unreadTracker.commentReports.count
        case .postReports: unreadTracker.postReports.count
        case .messageReports: unreadTracker.messageReports.count
        case .registrationApplications: unreadTracker.registrationApplications.count
        }
    }
}
