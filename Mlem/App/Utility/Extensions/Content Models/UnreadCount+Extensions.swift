//
//  UnreadCount+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension UnreadCount {
    var badgeLabel: String? {
        let total = LegacySettings.main.tabInboxBadgeIncludedTypes.reduce(0) { $0 + self[$1] }
        return total <= 0 ? nil : String(total)
    }
}
