//
//  Window.swift
//  Mlem
//
//  Created by tht7 on 01/07/2023.
//

import SwiftUI
import AlertToast

struct Window: View {
    @StateObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker = .init()
    @StateObject var communitySearchResultsTracker: CommunitySearchResultsTracker = .init()
    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()

    @State var selectedAccount: SavedAccount?
    
    @State var easterRewardsToastsQueue: [AlertToast] = .init()
    @State var easterRewardsToastDisaply: AlertToast?
    @State var easterRewardShouldShow = false

    var body: some View {
        ZStack {
            if let selectedAccount {
                view(for: selectedAccount)
            } else {
                NavigationStack {
                    AccountsPage(selectedAccount: $selectedAccount)
                }
            }
            
            // this is a hack since it seems .toast freaking loves reseting and redrawing everything 🙄
            Color.clear
                .toast(isPresenting: $easterRewardShouldShow, duration: 2.0) {
                    easterRewardsToastDisaply ?? AlertToast(displayMode: .hud, type: .error(.clear))
                } completion: {
                    if !easterRewardsToastsQueue.isEmpty {
                        easterRewardsToastDisaply = easterRewardsToastsQueue.popLast()
                        easterRewardShouldShow = true
                    }
                }
        }
        .onChange(of: selectedAccount) {
            if let host = $0?.instanceLink.host() {
                setEasterFlag("login:\(host)")
            }
        }
        .onAppear {
            if let host = selectedAccount?.instanceLink.host() {
                setEasterFlag("login:\(host)")
            }
        }
        .environment(\.setEasterFlag, setEasterFlag)
        .environmentObject(easterFlagsTracker)
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

    func setEasterFlag(_ flag: String) {
        let (isNew, _) = easterFlagsTracker.flags.insert(flag)
        
        if isNew, let rewards = easterReward[flag] {
            // time to display a cute message to the user about his new toy!
            for reward in rewards {
                switch reward {
                case let .icon(iconName, _):
                    easterRewardsToastsQueue.append(
                        AlertToast(
                            displayMode: .banner(.slide),
                            type: .regular,
                            title: "New icon unlocked!",
                            subTitle: "Unlocked the \"\(iconName)\" icon"
                        )
                    )
                }
            }
            
            if !easterRewardsToastsQueue.isEmpty {
                easterRewardsToastDisaply = easterRewardsToastsQueue.popLast()
                easterRewardShouldShow = true
            }
        }
    }
}
