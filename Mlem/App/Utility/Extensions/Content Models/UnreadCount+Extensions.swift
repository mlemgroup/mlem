//
//  UnreadCount+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/07/2024.
//

import MlemMiddleware

extension UnreadCount {
    var badgeLabel: String? {
        total <= 0 ? nil : String(total)
    }
}
