//
//  CommunitySortType+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

public extension CommunitySortType {
    // Source code for the conversions on PieFed's side:
    // https://codeberg.org/rimu/pyfedi/src/commit/d04a3ff48121fbf221404dcfacf52852ced1ad3b/app/api/alpha/utils/community.py#L98

    var pieFedSearchSortType: PieFedSearchSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .postCount: .topPosts
        case .federationDate(.ascending): .oldFederated
        case .federationDate(.descending): .newFederated
        case .subscriberCount: .topSubscribers
        case .newPostsOrComments: .active
        case .hot, .name, .commentCount,
             .activeUserCount,
             .localSubscriberCount: nil
        }
    }
}
