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
    /// This is only here so that sheet views that double as navigation views don't crash when they expect a navigation object. [2023.09]
    @StateObject private var navigation: Navigation = .init()

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
        /// Some views that participate in tab bar navigation may also be presented as sheets. This is purely a dummy, unused object passed to these sheets so that they don't crash. [2023.09]
            .environmentObject(navigation)
    }
    
    func forceOnboard() {
        selectedAccount = nil
    }
}
