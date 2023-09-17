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
    @StateObject var appState: AppState = .init()

    @State var flow: AppFlow

    var body: some View {
        content
            .id(appState.currentActiveAccount?.id ?? 0)
            .onChange(of: flow) { _ in flowDidChange() }
            .onAppear(perform: flowDidChange)
            .environment(\.setAppFlow, setFlow)
    }

    func flowDidChange() {
        hapticManager.initEngine()
        apiClient.configure(for: flow)
        
        switch flow {
        case .onboarding:
            appState.clearActiveAccount()
            favoriteCommunitiesTracker.clearStoredAccount()
        case let .account(account):
            appState.setActiveAccount(account)
            favoriteCommunitiesTracker.configure(for: account)
            siteInformation.load()
            
            if let host = account.instanceLink.host(),
               let instance = RecognizedLemmyInstances(rawValue: host) {
                easterFlagsTracker.setEasterFlag(.login(host: instance))
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch flow {
        case .onboarding:
            NavigationStack {
                OnboardingView(flow: $flow)
            }
        case let .account(account):
            view(for: account)
        }
    }
    
    @ViewBuilder
    private func view(for account: SavedAccount) -> some View {
        ContentView()
            .environmentObject(filtersTracker)
            .environmentObject(appState)
            .environmentObject(communitySearchResultsTracker)
            .environmentObject(recentSearchesTracker)
            .environmentObject(easterFlagsTracker)
            .environmentObject(layoutWidgetTracker)
            .environmentObject(pinnedViewOptionsTracker)
    }
    
    private func setFlow(_ flow: AppFlow) {
        self.flow = flow
    }
}
