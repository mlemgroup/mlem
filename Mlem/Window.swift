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
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()

    @State var selectedAccount: SavedAccount?

    var body: some View {
        content
            .onChange(of: selectedAccount) { _ in onLogin() }
            .onAppear(perform: onLogin)
            .environment(\.forceOnboard, forceOnboard)
    }

    func onLogin() {
        if let host = selectedAccount?.instanceLink.host(),
           let instance = RecognizedLemmyInstances(rawValue: host) {
            easterFlagsTracker.setEasterFlag(.login(host: instance))
        }
        
        hapticManager.initEngine()
    }
    
    @ViewBuilder
    private var content: some View {
        if let selectedAccount {
            view(for: selectedAccount)
        } else {
            NavigationStack {
                AddSavedInstanceView(onboarding: true, currentAccount: $selectedAccount)
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
            .environmentObject(easterFlagsTracker)
            .environmentObject(layoutWidgetTracker)
    }
    
    func forceOnboard() {
        selectedAccount = nil
    }
}
