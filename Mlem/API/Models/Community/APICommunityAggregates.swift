//
//  APICommunityAggregates.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

// lemmy_db_schema::aggregates::structs::CommunityAggregates
struct APICommunityAggregates: Decodable {
    internal init(
        id: Int = 0,
        communityId: Int = 0,
        subscribers: Int = 42349,
        subscribersLocal: Int = 2043,
        posts: Int = 300,
        comments: Int = 5000,
        published: Date = .mock,
        usersActiveDay: Int = 3040,
        usersActiveWeek: Int = 20044,
        usersActiveMonth: Int = 50403,
        usersActiveHalfYear: Int = 73032
    ) {
        self.id = id
        self.communityId = communityId
        self.subscribers = subscribers
        self.subscribersLocal = subscribersLocal
        self.posts = posts
        self.comments = comments
        self.published = published
        self.usersActiveDay = usersActiveDay
        self.usersActiveWeek = usersActiveWeek
        self.usersActiveMonth = usersActiveMonth
        self.usersActiveHalfYear = usersActiveHalfYear
    }
    
    let id: Int? // TODO: 0.18 Deprecation remove this field
    let communityId: Int
    let subscribers: Int
    let subscribersLocal: Int?
    let posts: Int
    let comments: Int
    let published: Date
    let usersActiveDay: Int
    let usersActiveWeek: Int
    let usersActiveMonth: Int
    let usersActiveHalfYear: Int
}

extension APICommunityAggregates: Mockable {
    static var mock: APICommunityAggregates = .init()
}
