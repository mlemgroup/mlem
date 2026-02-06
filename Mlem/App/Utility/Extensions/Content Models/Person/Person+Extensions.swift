//
//  Person+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-06.
//

import MlemMiddleware

extension Person {
    var shouldHideInFeed: Bool { blocked || purged }
}
