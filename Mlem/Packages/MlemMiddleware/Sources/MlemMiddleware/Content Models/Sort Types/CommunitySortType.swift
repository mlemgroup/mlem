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

    public static let basicCases: [CommunitySortType] = [
        .hot,
        .new,
        .old,
        .commentCount,
        .postCount,
        .subscriberCount,
        .localSubscriberCount,
        .newPostsOrComments
    ]

    public static let allCases: [CommunitySortType] = basicCases + [
        .name(.ascending),
        .name(.descending),
        .activeUserCount(.sixMonths),
        .activeUserCount(.month),
        .activeUserCount(.week),
        .activeUserCount(.day),
        .federationDate(.ascending),
        .federationDate(.descending)
    ]
}
