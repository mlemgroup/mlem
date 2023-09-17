//
//  Window.swift
//  Mlem
//
//  Created by tht7 on 01/07/2023.
//

import Dependencies
import SwiftUI

struct Window: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.siteInformation) var siteInformation

    @StateObject var communitySearchResultsTracker: CommunitySearchResultsTracker = .init()
    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()
    @StateObject var pinnedViewOptionsTracker: PinnedViewOptionsTracker = .init()

    @State var selectedAccount: SavedAccount?

    var body: some View {
        content
            .onChange(of: selectedAccount) { _ in onLogin() }
            .onAppear(perform: onLogin)
            .environment(\.forceOnboard, forceOnboard)
    }

    func onLogin() {
        hapticManager.initEngine()
        
        guard let selectedAccount else { return }
        
        apiClient.configure(for: selectedAccount)
        favoriteCommunitiesTracker.configure(for: selectedAccount)
        siteInformation.load()
        
        if let host = selectedAccount.instanceLink.host(),
           let instance = RecognizedLemmyInstances(rawValue: host) {
            easterFlagsTracker.setEasterFlag(.login(host: instance))
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if let selectedAccount {
            view(for: selectedAccount)
        } else {
            NavigationStack {
                OnboardingView(selectedAccount: $selectedAccount)
            }
        }
    }
    
    @ViewBuilder
    private func view(for account: SavedAccount) -> some View {
        ContentView()
            .id(account.id)
            .environmentObject(filtersTracker)
            .environmentObject(AppState(defaultAccount: account, selectedAccount: $selectedAccount))
            .environmentObject(communitySearchResultsTracker)
            .environmentObject(recentSearchesTracker)
            .environmentObject(easterFlagsTracker)
            .environmentObject(layoutWidgetTracker)
            .environmentObject(pinnedViewOptionsTracker)
    }
    
    func forceOnboard() {
        selectedAccount = nil
    }
}
