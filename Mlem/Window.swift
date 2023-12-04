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
    @Dependency(\.accountsTracker) var accountsTracker

    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()
    @StateObject var appState: AppState = .init()

    @State var flow: AppFlow
    
    @State private var navigationPath = NavigationPath() // for reauthentication case

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
        case let .reauthenticating(account):
            appState.clearActiveAccount()
            accountsTracker.removeAccount(account: account)
        case let .account(account):
            // pop reauth sheet if login credentials invalid
            Task {
                do {
                    try await apiClient.checkLogin()
                    print("login check succeeded")
                } catch {
                    print("login check failed")
                    setFlow(.reauthenticating(account))
                }
            }
            
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
            LandingPage()
        case let .reauthenticating(account):
            if let instance = account.hostName {
                NavigationStack(path: $navigationPath) {
                    AddSavedInstanceView(loginType: .reauthenticating(instance, account.username), displayMode: .nav)
                }
            } else {
                // not ideal but it should be basically impossible to get here
                view(for: account)
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
            .environmentObject(recentSearchesTracker)
            .environmentObject(easterFlagsTracker)
            .environmentObject(layoutWidgetTracker)
    }
    
    private func setFlow(_ flow: AppFlow) {
        transition(flow)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.flow = flow
        }
    }
    
    /// This method changes the current application flow and places a _transition_ view across the active window while
    /// - Parameter newFlow: The `AppFlow` that the application should transition into
    private func transition(_ newFlow: AppFlow) {
        let transitionType: TransitionType
        switch newFlow {
        case .onboarding:
            transitionType = .goingToOnboarding
        case .reauthenticating:
            transitionType = .reauthenticating
        case let .account(account):
            transitionType = .switchingAccount(account.nickname)
        }
        
        Task { @MainActor in
            
            let transition = TransitionView(transitionType: transitionType)
            guard let transitionView = UIHostingController(rootView: transition).view,
                  let window = UIApplication.shared.firstKeyWindow else {
                return
            }
            
            transitionView.alpha = 0
            window.addSubview(transitionView)
            UIView.animate(withDuration: 0.15) {
                transitionView.alpha = 1
            }
            
            transitionView.translatesAutoresizingMaskIntoConstraints = false
            transitionView.heightAnchor.constraint(equalTo: window.heightAnchor).isActive = true
            transitionView.widthAnchor.constraint(equalTo: window.widthAnchor).isActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIView.animate(withDuration: 0.3) {
                    transitionView.alpha = 0
                } completion: { _ in
                    transitionView.removeFromSuperview()
                }
            }
        }
    }
}
