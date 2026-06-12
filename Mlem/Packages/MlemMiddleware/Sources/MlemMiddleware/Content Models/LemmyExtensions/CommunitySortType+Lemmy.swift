//
//  CommunitySortType+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

// MARK:- v3

extension CommunitySortType {
    // Source code for the conversions on Lemmy's side:
    // https://github.com/LemmyNet/lemmy/blob/1846ae9e19e7a2d8eb275c3f6406770a552f5647/crates/db_views_actor/src/community_view.rs#L170

    internal var v3ApiType: LemmySortType? {
        switch self {
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .commentCount: .mostComments
        case .subscriberCount: .topAll
        case .activeUserCount(.sixMonths): .topSixMonths
        case .activeUserCount(.month): .topMonth
        case .activeUserCount(.week): .topWeek
        case .activeUserCount(.day): .topDay
        case .newPostsOrComments, .name, .postCount, .localSubscriberCount, .federationDate: nil
        }
    }
}

// MARK:- v4

extension CommunitySortType {
    internal var v4ApiType: LemmyCommunitySortType? {
        switch self {
        case .hot: .hot
        case .new: .new
        case .old: .old
        case .name(.ascending): .nameAsc
        case .name(.descending): .nameDesc
        case .commentCount: .comments
        case .postCount: .posts
        case .subscriberCount: .subscribers
        case .localSubscriberCount: .subscribersLocal
        case .activeUserCount(.sixMonths): .activeSixMonths
        case .activeUserCount(.month): .activeMonthly
        case .activeUserCount(.week): .activeWeekly
        case .activeUserCount(.day): .activeDaily
        case .federationDate, .newPostsOrComments: nil
        }
    }
}
