//
//  InboxItemType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-17.
//

import Foundation
import Icons
import MlemMiddleware

extension InboxItemType {
    var label: LocalizedStringResource {
        switch self {
        case .reply: "Replies"
        case .mention: "Mentions"
        case .message: "Messages"
        case .postReport: "Post Reports"
        case .commentReport: "Comment Reports"
        case .messageReport: "Message Reports"
        case .registrationApplication: "Registration Applications"
        }
    }
    
    fileprivate var labelOnly: LocalizedStringResource {
        switch self {
        case .reply: "Replies Only"
        case .mention: "Mentions Only"
        case .message: "Messages Only"
        case .postReport: "Post Reports Only"
        case .commentReport: "Comment Reports Only"
        case .messageReport: "Message Reports Only"
        case .registrationApplication: "Applications Only"
        }
    }
    
    fileprivate var labelExcept: LocalizedStringResource {
        switch self {
        case .reply: "Except Replies"
        case .mention: "Except Mentions"
        case .message: "Except Messages"
        case .postReport: "Except Post Reports"
        case .commentReport: "Except Comment Reports"
        case .messageReport: "Except Message Reports"
        case .registrationApplication: "Except Applications"
        }
    }
    
    var icon: Icon {
        switch self {
        case .reply: .lemmy.reply
        case .mention: .lemmy.mention
        case .message: .lemmy.message
        case .postReport: .lemmy.post
        case .commentReport: .lemmy.replies
        case .messageReport: .lemmy.report
        case .registrationApplication: .lemmy.registrationApplication
        }
    }
    
    var requiredAccountType: AccountType {
        switch self {
        case .reply: .user
        case .mention: .user
        case .message: .user
        case .postReport: .moderator
        case .commentReport: .moderator
        case .messageReport: .admin
        case .registrationApplication: .admin
        }
    }
}

extension Sequence<InboxItemType> {
    func label(accountType: AccountType) -> String {
        let items = Set(filter { accountType >= $0.requiredAccountType })
        let allItems = Set<InboxItemType>.all.filter { accountType >= $0.requiredAccountType }
        
        if items.isEmpty { return .init(localized: "None") }
        
        if items == allItems {
            return .init(localized: "All")
        }
        if items == .personal {
            return .init(localized: "Personal Only")
        }
        if accountType >= .moderator, items == .reports.filter({ accountType >= $0.requiredAccountType }) {
            return .init(localized: "Reports Only")
        }
        
        if accountType == .admin, items == .moderatorAndAdmin {
            return .init(localized: "Mod Mail Only")
        }
        
        if items.count == 2 {
            return items.map { String(localized: $0.label) }.sorted().joined(separator: " & ")
        }
        if items.count == 1, let first = items.first {
            return .init(localized: first.labelOnly)
        }
        
        let disabledItems = allItems.subtracting(items)
        if disabledItems.count == 1, let first = disabledItems.first {
            return .init(localized: first.labelExcept)
        }
        
        return .init(localized: "Some")
    }
}
