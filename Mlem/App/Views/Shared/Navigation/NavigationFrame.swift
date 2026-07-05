//
//  NavigationFrame.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-03.
//

import Foundation

// This exists to fix the following issue:
// https://github.com/mlemgroup/mlem/issues/2533

@Observable
class NavigationFrame: Hashable {
    var page: NavigationPage

    init(page: NavigationPage) {
        self.page = page
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: NavigationFrame, rhs: NavigationFrame) -> Bool {
        lhs === rhs
    }
}
