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
        subscribers: Int = 0,
        posts: Int = 0,
        comments: Int = 0,
        published: Date = .mock,
        usersActiveDay: Int = 0,
        usersActiveWeek: Int = 0,
        usersActiveMonth: Int = 0,
        usersActiveHalfYear: Int = 0
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
