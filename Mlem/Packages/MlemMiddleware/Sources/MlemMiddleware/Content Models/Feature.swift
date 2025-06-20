//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public enum Feature: Hashable {
    case postSortType(PostSortType)
    case commentSortType(CommentSortType)
    case searchSortType(SearchSortType)
    case sortTimeRange(SortTimeRange)

    // On some earlier Lemmy versions, legacy report types are used
    case fullyFeaturedReports
    
    case searchLocalPeople
    
    // On Lemmy, admins were able to view votes before moderators were able to
    case moderatorsCanViewVotes
    
    case hidePosts
}
