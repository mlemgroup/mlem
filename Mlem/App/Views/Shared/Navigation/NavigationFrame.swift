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
    private(set) var page: NavigationPage
    private var updateCount: Int = 0

    init(page: NavigationPage) {
        self.page = page
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    func replacePage(with page: NavigationPage) {
        self.page = page
        self.updateCount += 1
    }

    var updateCountHash: Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(self))
        hasher.combine(updateCount)
        return hasher.finalize()
    }

    public static func == (lhs: NavigationFrame, rhs: NavigationFrame) -> Bool {
        lhs === rhs
    }
}
