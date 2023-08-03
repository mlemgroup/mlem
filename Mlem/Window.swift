//
//  Window.swift
//  Mlem
//
//  Created by tht7 on 01/07/2023.
//

import Dependencies
import SwiftUI

struct Window: View {
    
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    
    @StateObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker = .init()
    @StateObject var communitySearchResultsTracker: CommunitySearchResultsTracker = .init()
    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()

    @State var selectedAccount: SavedAccount?

    var body: some View {
        content
            .onChange(of: selectedAccount) { _ in onLogin() }
            .onAppear(perform: onLogin)
            .environment(\.forceOnboard, forceOnboard)
            .environment(\.setEasterFlag, setEasterFlag)
            .environmentObject(easterFlagsTracker)
    }
    
    @ViewBuilder
    var content: some View {
        if let selectedAccount {
            view(for: selectedAccount)
        } else {
            NavigationStack {
                AddSavedInstanceView(onboarding: true, currentAccount: $selectedAccount)
            }
        }
    }

    func onLogin() {
        // set easter flags
        if let host =
            RecognizedLemmyInstances(rawValue:
                                        selectedAccount?.instanceLink.host() ?? "unknown"
            ) {
            setEasterFlag(.login(host: host))
        }
        
        _ = hapticManager.initEngine()
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

    func setEasterFlag(_ flag: EasterFlag) {
        let (isNew, _) = easterFlagsTracker.flags.insert(flag)
        
        if isNew, let rewards = easterReward[flag] {
            // time to display a cute message to the user about his new toy!
            Task {
                await notifier.add(rewards)
            }
        }
    }
    
    func forceOnboard() {
        selectedAccount = nil
    }
}
