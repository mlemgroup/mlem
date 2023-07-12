//
//  Window.swift
//  Mlem
//
//  Created by tht7 on 01/07/2023.
//

import SwiftUI

struct Window: View {
    @StateObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker = .init()
    @StateObject var communitySearchResultsTracker: CommunitySearchResultsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()
    
    @State var selectedAccount: SavedAccount?
    
    var body: some View {
        if let selectedAccount {
            view(for: selectedAccount)
        } else {
            NavigationStack {
                AccountsPage(selectedAccount: $selectedAccount)
            }
        }
    }
    
    @ViewBuilder
    private func view(for account: SavedAccount) -> some View {
        ContentView()
            .id(account.id)
            .environmentObject(filtersTracker)
            .environmentObject(AppState(defaultAccount: account, selectedAccount: $selectedAccount))
            .environmentObject(favoriteCommunitiesTracker)
            .environmentObject(communitySearchResultsTracker)
            .environmentObject(recentSearchesTracker)
            .onChange(of: filtersTracker.filteredKeywords) { saveFilteredKeywords($0) }
            .onChange(of: favoriteCommunitiesTracker.favoriteCommunities) { saveFavouriteCommunities($0) }
    }
    
    private func saveFilteredKeywords(_ newValue: [String]) {
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
    
    private func saveFavouriteCommunities(_ newValue: [FavoriteCommunity]) {
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
