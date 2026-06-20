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
    case communitySortType(CommunitySortType)
    case personSortType(PersonSortType)
    case sortTimeRange(SortTimeRange)
    case listingType(ListingType)
    
    case hidePosts
    case searchLocalComments

    case modlog
    case viewInstanceCreationDate
    case viewInstanceSettings
    
    case logIn
    case signUp
    
    case viewReports
    
    case reportPrivateMessages
    case purgeContent
    case removeCommunity
    case banFromInstance
    
    case banFromNonLocalCommunity
    
    case unbanWithReason
    
    /// Add/remove moderators from a community
    case editModeratorList
    
    case uploadImages

    case editAccountSettings
    case editDisplayName
    
    case viewInstanceBlockList
    case moderatorSetNsfw
    
    case fetchLinkMetadata
    case customPostThumbnail

    case userNotes
    case toggleNotifications
}
