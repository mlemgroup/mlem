//
//  Window.swift
//  Mlem
//
//  Created by tht7 on 01/07/2023.
//

import SwiftUI

struct Window: View {
    @StateObject var appState: AppState = .init()
    @StateObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker = .init()
    @StateObject var communitySearchResultsTracker: CommunitySearchResultsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    
    var body: some View {
        ContentView()
            .environmentObject(filtersTracker)
            .environmentObject(appState)
            .environmentObject(favoriteCommunitiesTracker)
            .environmentObject(communitySearchResultsTracker)
            .onAppear {
                if FileManager.default.fileExists(atPath: AppConstants.filteredKeywordsFilePath.path) {
                    print("Filtered keywords file exists, will attempt to load blocked keywords")
                    do {
                        filtersTracker.filteredKeywords = try decodeFromFile(
                            fromURL: AppConstants.filteredKeywordsFilePath,
                            whatToDecode: .filteredKeywords
                        ) as? [String] ?? []
                    } catch let savedKeywordsDecodingError {
                        print("Failed while decoding saved filtered keywords: \(savedKeywordsDecodingError)")
                    }
                } else {
                    print("Filtered keywords file does not exist, will try to create it")
                    
                    do {
                        try createEmptyFile(at: AppConstants.filteredKeywordsFilePath)
                    } catch let emptyFileCreationError {
                        print("Failed while creating an empty file: \(emptyFileCreationError)")
                    }
                }
                print("now filtering: \(filtersTracker.filteredKeywords.count)")
                if FileManager.default.fileExists(atPath: AppConstants.favoriteCommunitiesFilePath.path) {
                    print("Favorite communities file exists, will attempt to load favorite communities")
                    do {
                        favoriteCommunitiesTracker.favoriteCommunities = try decodeFromFile(
                            fromURL: AppConstants.favoriteCommunitiesFilePath,
                            whatToDecode: .favoriteCommunities
                        ) as? [FavoriteCommunity] ?? []
                    } catch let favoriteCommunitiesDecodingError {
                        print("Failed while decoding favorite communities: \(favoriteCommunitiesDecodingError)")
                    }
                } else {
                    print("Favorite communities file does not exist, will try to create it")

                    do {
                        try createEmptyFile(at: AppConstants.favoriteCommunitiesFilePath)
                    } catch let emptyFileCreationError {
                        print("Failed while creating empty file: \(emptyFileCreationError)")
                    }
                }
            }
            .onChange(of: filtersTracker.filteredKeywords) { newValue in
                print("Change detected in filtered keywords: \(newValue)")
                do {
                    let encodedFilteredKeywords: Data = try encodeForSaving(object: newValue)

                    print(encodedFilteredKeywords)
                    do {
                        try writeDataToFile(data: encodedFilteredKeywords, fileURL: AppConstants.filteredKeywordsFilePath)
                    } catch let writingError {
                        print("Failed while saving data to file: \(writingError)")
                    }
                } catch let encodingError {
                    print("Failed while encoding filters to data: \(encodingError)")
                }
            }
            .onChange(of: favoriteCommunitiesTracker.favoriteCommunities) { newValue in
                print("Change detected in favorited communities")

                do {
                    let encodedFavoriteCommunities: Data = try encodeForSaving(object: newValue)

                    do {
                        try writeDataToFile(data: encodedFavoriteCommunities, fileURL: AppConstants.favoriteCommunitiesFilePath)
                    } catch let writingError {
                        print("Failed while saving data to file: \(writingError)")
                    }
                } catch let encodingError {
                    print("Failed while encoding favorited communities to data: \(encodingError)")
                }
            }

    }
}
