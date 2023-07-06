//
//  Favorites Tracker.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation

class FavoriteCommunitiesTracker: ObservableObject {
    @Published var favoriteCommunities: [FavoriteCommunity] = .init()

    init(favoriteCommunities: [FavoriteCommunity]? = nil) {
        self.favoriteCommunities = favoriteCommunities ?? FavoriteCommunitiesTracker.loadFavorites()
    }

    static func loadFavorites() -> [FavoriteCommunity] {
        if FileManager.default.fileExists(atPath: AppConstants.favoriteCommunitiesFilePath.path) {
            do {
                return try decodeFromFile(
                    fromURL: AppConstants.favoriteCommunitiesFilePath,
                    whatToDecode: .favoriteCommunities
                ) as? [FavoriteCommunity] ?? []
            } catch {
            }
            // TODO: Hande
        } else {
            // TODO: - AppConstants proper emptyFileCreationError handling
            do {
                try createEmptyFile(at: AppConstants.favoriteCommunitiesFilePath)
            } catch {
                // TODO: Hande
            }
        }
        return []
    }
}
