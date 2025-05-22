//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-22.
//

import Foundation

extension ApiCommunityAggregates {
    static var zero: Self {
        .init(
            communityId: 0,
            subscribers: 0,
            posts: 0,
            comments: 0,
            published: .distantPast,
            usersActiveDay: 0,
            usersActiveWeek: 0,
            usersActiveMonth: 0,
            usersActiveHalfYear: 0,
            subscribersLocal: 0
        )
    }
}
