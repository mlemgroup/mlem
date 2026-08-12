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
        case .personal: "Personal"
        case .moderation: "Mod Mail"
        }
    }
    
    var icon: Icon {
        switch self {
        case .personal: .lemmy.replies
        case .moderation: .lemmy.moderation
        }
    }
}

extension Sequence<InboxItemType> {
    var label: LocalizedStringResource {
        switch Set(self) {
        case [.personal, .moderation]: "All"
        case [.personal]: "Personal Only"
        case [.moderation]: "Mod Mail Only"
        default: "Off"
        }
    }
}
