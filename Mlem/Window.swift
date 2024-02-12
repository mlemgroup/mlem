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
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.siteInformation) var siteInformation
    
    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()
    
    @State var apiSource: any APISource
    @State var myInstance: Instance3?
    @State var myUser: User3?
    
    @State var isOnboarding: Bool = false
    @State var loadedInitialFlow: Bool = false
    
    var body: some View {
        content
            .id(apiSource.actorId)
            .task(id: apiSource.actorId) {
                if apiSource is any AuthenticatedUserProviding {
                    if let host = account.actorId.host(),
                       let instance = RecognizedLemmyInstances(rawValue: host) {
                        easterFlagsTracker.setEasterFlag(.login(host: instance))
                    }
                } else {
                    self.myInstance = try await apiSource.instance.upgrade()
                }
            }
            .onAppear {
                if !loadedInitialFlow {
                    hapticManager.initEngine()
                    loadedInitialFlow = true
                }
            }
            .environment(\.setAppFlow, setFlow)
            .environment(\.apiSource, apiSource)
    }
    
    @ViewBuilder
    private var content: some View {
        if isOnboarding {
            LandingPage()
        } else {
            ContentView()
                .environment(\.myUser, myUser)
                .environment(\.myInstance, myInstance)
                .environmentObject(filtersTracker)
                .environmentObject(appState)
                .environmentObject(recentSearchesTracker)
                .environmentObject(easterFlagsTracker)
                .environmentObject(layoutWidgetTracker)
        }
    }
}
