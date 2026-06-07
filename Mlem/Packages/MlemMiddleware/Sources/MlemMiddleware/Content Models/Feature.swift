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
    case searchSortType(SearchSortType)
    case sortTimeRange(SortTimeRange)
    case listingType(ListingType)
    
    case viewVotes
    
    case hidePosts
    case searchLocalPeople
    case searchLocalCommunities
    case searchLocalComments

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
    case banFromNonLocalCommunity
    
    case unbanWithReason
    
    /// Add/remove moderators from a community
    case editModeratorList
    case editCommunityDescription
    
    case uploadImages
    case commentSearch

    case editProfile
    case editAccountSettings
    case editDisplayName
    
    /// Server automatically marks posts as read when voted on or saved
    case autoMarkPostReadOnInteract
    
    case blockInstances
    case viewInstanceBlockList
    case moderatorSetNsfw
    
    case fetchLinkMetadata
    case customPostThumbnail

    case userNotes
}
