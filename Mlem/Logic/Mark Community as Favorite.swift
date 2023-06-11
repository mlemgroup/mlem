//
//  Favorite Community.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation

func favoriteCommunity(account: SavedAccount, community: APICommunity, favoritedCommunitiesTracker: FavoriteCommunitiesTracker) -> Void
{
    favoritedCommunitiesTracker.favoriteCommunities.append(FavoriteCommunity(forAccountID: account.id, community: community))
}
