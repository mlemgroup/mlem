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
//            print("Favorite communities file exists, will attempt to load favorite communities")
            do {
                return try decodeFromFile(
                    fromURL: AppConstants.favoriteCommunitiesFilePath,
                    whatToDecode: .favoriteCommunities
                ) as? [FavoriteCommunity] ?? []
            } catch let favoriteCommunitiesDecodingError {
//                print("Failed while decoding favorite communities: \(favoriteCommunitiesDecodingError)")
            }
        } else {
//            print("Favorite communities file does not exist, will try to create it")
            do {
                try createEmptyFile(at: AppConstants.favoriteCommunitiesFilePath)
            } catch let emptyFileCreationError {
//                print("Failed while creating empty file: \(emptyFileCreationError)")
            }
        }
        return []
    }
}
