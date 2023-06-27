//
//  Get Favorited Communities.swift
//  Mlem
//
//  Created by Jake Shirley on 6/18/23.
//

import Foundation

func getFavoritedCommunities(account: SavedAccount, favoritedCommunitiesTracker: FavoriteCommunitiesTracker) -> [APICommunity] {
    return favoritedCommunitiesTracker.favoriteCommunities
        .filter { $0.forAccountID == account.id }
        .map { $0.community }
        .sorted(by: { $0.name < $1.name })
}
