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
    
    case adminsCanViewVotes
    // On Lemmy, admins were able to view votes before moderators were able to
    case moderatorsCanViewVotes
    
    case hidePosts
    case searchLocalPeople
    case searchLocalCommunities

    case modlog
    case viewInstanceCreationDate
    case viewInstanceSettings
    case viewCommunityActiveUsers
    
    case logIn
    case signUp
    
    case viewReports
    case viewMentionsAndPrivateMessages
    
    case editAndDeletePrivateMessages
    case undeletePrivateMessages
    case reportPrivateMessages
    case purgeContent
    case removeCommunity
    case banFromInstance
    case banFromCommunity
    
    // Add/remove moderators from a community
    case editModeratorList
    
    case commentTreeSortedByDepth
    case uploadImages
    case editAccountSettings
    case commentSearch
}
