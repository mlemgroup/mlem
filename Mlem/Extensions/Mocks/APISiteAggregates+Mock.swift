//
//  APISiteAggregates+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

extension APISiteAggregates {
    static func mock(
        siteId: Int = 0,
        users: Int = 39453,
        posts: Int = 1856,
        comments: Int = 20371,
        communities: Int = 183,
        usersActiveDay: Int = 284,
        usersActiveWeek: Int = 4038,
        usersActiveMonth: Int = 8079,
        usersActiveHalfYear: Int = 10200
    ) -> APISiteAggregates {
        .init(
            id: nil,
            siteId: siteId,
            users: users,
            posts: posts,
            comments: comments,
            communities: communities,
            usersActiveDay: usersActiveDay,
            usersActiveWeek: usersActiveWeek,
            usersActiveMonth: usersActiveMonth,
            usersActiveHalfYear: usersActiveHalfYear
        )
    }
}
