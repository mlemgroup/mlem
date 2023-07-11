//
//  Remove Community from Favorites.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation

func unfavoriteCommunity(community: APICommunity, favoritedCommunitiesTracker: FavoriteCommunitiesTracker) {
    favoritedCommunitiesTracker.favoriteCommunities.removeAll(where: { $0.community.id == community.id })
}
