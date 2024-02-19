//
//  APICommunityAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommunityAggregates.ts
struct APICommunityAggregates: Codable {
    let community_id: Int
    let subscribers: Int
    let posts: Int
    let comments: Int
    let published: String
    let users_active_day: Int
    let users_active_week: Int
    let users_active_month: Int
    let users_active_half_year: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "community_id", value: String(community_id)),
            .init(name: "subscribers", value: String(subscribers)),
            .init(name: "posts", value: String(posts)),
            .init(name: "comments", value: String(comments)),
            .init(name: "published", value: published),
            .init(name: "users_active_day", value: String(users_active_day)),
            .init(name: "users_active_week", value: String(users_active_week)),
            .init(name: "users_active_month", value: String(users_active_month)),
            .init(name: "users_active_half_year", value: String(users_active_half_year))
        ]
    }
}
