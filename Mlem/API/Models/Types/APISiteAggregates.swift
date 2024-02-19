//
//  APISiteAggregates.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/SiteAggregates.ts
struct APISiteAggregates: Codable {
    let site_id: Int
    let users: Int
    let posts: Int
    let comments: Int
    let communities: Int
    let users_active_day: Int
    let users_active_week: Int
    let users_active_month: Int
    let users_active_half_year: Int

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "site_id", value: String(site_id)),
            .init(name: "users", value: String(users)),
            .init(name: "posts", value: String(posts)),
            .init(name: "comments", value: String(comments)),
            .init(name: "communities", value: String(communities)),
            .init(name: "users_active_day", value: String(users_active_day)),
            .init(name: "users_active_week", value: String(users_active_week)),
            .init(name: "users_active_month", value: String(users_active_month)),
            .init(name: "users_active_half_year", value: String(users_active_half_year))
        ]
    }
}
