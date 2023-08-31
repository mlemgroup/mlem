//
//  CommunityListSidebarEntry.swift
//  Mlem
//
//  Created by Jake Shirley on 6/19/23.
//

import Dependencies
import Foundation

protocol SidebarEntry {
    var sidebarLabel: String? { get }
    var sidebarIcon: String? { get }
    
    func contains(community: APICommunity, isSubscribed: Bool) -> Bool
}

// Filters no communities, used for top entry in sidebar
struct EmptySidebarEntry: SidebarEntry {
    var sidebarLabel: String?
    var sidebarIcon: String?

    func contains(community: APICommunity, isSubscribed: Bool) -> Bool {
        false
    }
}

// Filters based on community name
struct RegexCommunityNameSidebarEntry: SidebarEntry {
    var communityNameRegex: Regex<Substring>
    var sidebarLabel: String?
    var sidebarIcon: String?

    func contains(community: APICommunity, isSubscribed: Bool) -> Bool {
        // Ignore unsubscribed subs from main list
        if !isSubscribed {
            return false
        }
        return community.name.starts(with: communityNameRegex)
    }
}

// Filters to favorited communities
struct FavoritesSidebarEntry: SidebarEntry {
    
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    
    var sidebarLabel: String?
    var sidebarIcon: String?

    @MainActor
    func contains(community: APICommunity, isSubscribed: Bool) -> Bool {
        favoriteCommunitiesTracker.favoritesForCurrentAccount
            .map { $0.community }
            .contains(community)
    }
}
