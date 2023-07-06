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
