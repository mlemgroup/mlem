//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-22.
//

import Foundation

extension LemmySiteAggregates {
    static var zero: Self {
        .init(
            siteId: 0,
            users: 0,
            posts: 0,
            comments: 0,
            communities: 0,
            usersActiveDay: 0,
            usersActiveWeek: 0,
            usersActiveMonth: 0,
            usersActiveHalfYear: 0
        )
    }
}
