//
//  APICommunityAggregates+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension APICommunityAggregates {
    static func mock(
        id: Int = 0,
        communityId: Int = 0,
        subscribers: Int = 42349,
        posts: Int = 300,
        comments: Int = 5000,
        published: Date = .mock,
        usersActiveDay: Int = 3040,
        usersActiveWeek: Int = 20044,
        usersActiveMonth: Int = 50403,
        usersActiveHalfYear: Int = 73032
    ) -> APICommunityAggregates {
        .init(
            id: id,
            communityId: communityId,
            subscribers: subscribers,
            posts: posts,
            comments: comments,
            published: published,
            usersActiveDay: usersActiveDay,
            usersActiveWeek: usersActiveWeek,
            usersActiveMonth: usersActiveMonth,
            usersActiveHalfYear: usersActiveHalfYear
        )
    }
}
