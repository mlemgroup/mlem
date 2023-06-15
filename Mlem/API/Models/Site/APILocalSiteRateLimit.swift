//
//  APILocalSiteRateLimit.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12/06/2023.
//

import Foundation

// lemmy_db_schema::source::local_site_rate_limit::LocalSiteRateLimit
// this structure is in the form of:
// <X>: (X rate limit amount per time window)
// <X>_per_second: (rate limit time window in seconds)
struct APILocalSiteRateLimit: Decodable {
    let id: Int
    let localSiteId: Int
    let message: Int
    let messagePerSecond: Int
    let post: Int
    let postPerSecond: Int
    let register: Int
    let registerPerSecond: Int
    let image: Int
    let imagePerSecond: Int
    let comment: Int
    let commentPerSecond: Int
    let search: Int
    let searchPerSecond: Int
    let published: Date
    let updated: Date?
}
