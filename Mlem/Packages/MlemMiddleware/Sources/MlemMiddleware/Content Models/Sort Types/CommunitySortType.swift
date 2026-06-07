//
//  CommunitySortType.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

public enum CommunitySortType: Hashable, Sendable, CaseIterable {
    case hot
    case new
    case old
    case name(SortDirection)
    case commentCount
    case postCount
    case subscriberCount
    case localSubscriberCount
    case activeUserCount(ActiveUserTimeRange)
    case federationDate(SortDirection)

    // Sort by the date of the last post or comment made to the community
    case newPostsOrComments

    public static var allCases: [CommunitySortType] = [
        .hot,
        .new,
        .old,
        .name(.ascending),
        .name(.descending),
        .commentCount,
        .postCount,
        .subscriberCount,
        .localSubscriberCount,
        .activeUserCount(.sixMonth),
        .activeUserCount(.month),
        .activeUserCount(.week),
        .activeUserCount(.day),
        .federationDate(.ascending),
        .federationDate(.descending),
        .newPostsOrComments
    ]
}
