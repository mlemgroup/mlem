//
//  Favorites Tracker.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation

class FavoriteCommunitiesTracker: ObservableObject {
    @Published var favoriteCommunities: [FavoriteCommunity] = .init()

    init(favoriteCommunities: [FavoriteCommunity] = []) {
        self.favoriteCommunities = favoriteCommunities
    }
}
