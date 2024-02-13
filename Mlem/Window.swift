//
//  Window.swift
//  Mlem
//
//  Created by tht7 on 01/07/2023.
//

import Dependencies
import SwiftUI

@Observable
class NewAppState {
    var isOnboarding: Bool = false
    
    var apiSource: (any APISource)? {
        didSet {
            myInstance = apiSource?.instance
            myUser = apiSource as? MyUserStub
        }
    }
    var myInstance: (any InstanceStubProviding)?
    var myUser: (any MyUserProviding)?
    
    var api: NewAPIClient? { apiSource?.api }
    var actorId: URL? { apiSource?.actorId }
    var instanceStub: NewInstanceStub? { apiSource?.instance }
    
    init(apiSource: (any APISource)?) {
        self.apiSource = apiSource
        if apiSource == nil {
            self.isOnboarding = true
        }
    }
    
    func setApiSource(_ source: any APISource) {
        self.apiSource = source
    }
}

struct Window: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.errorHandler) var errorHandler
    
    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()
    
    var appState: NewAppState
    
    @State var loadedInitialFlow: Bool = false
    
    var body: some View {
        content
            .id(appState.actorId)
            .task(id: appState.actorId) {
                if appState.apiSource is any MyUserProviding {
                    if let host = appState.actorId?.host(),
                       let instance = RecognizedLemmyInstances(rawValue: host) {
                        easterFlagsTracker.setEasterFlag(.login(host: instance))
                    }
                } else {
                    do {
                        appState.myInstance = try await appState.instanceStub?.upgrade()
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
            .onAppear {
                if !loadedInitialFlow {
                    hapticManager.initEngine()
                    loadedInitialFlow = true
                }
            }
            .environment(appState)
    }
    
    @ViewBuilder
    private var content: some View {
        if appState.isOnboarding {
            LandingPage()
        } else {
            ContentView()
                .environmentObject(filtersTracker)
                .environmentObject(recentSearchesTracker)
                .environmentObject(easterFlagsTracker)
                .environmentObject(layoutWidgetTracker)
        }
    }
}
