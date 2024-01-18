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
    @StateObject var appState: AppState = .init()

    @State var flow: AppFlow

    var body: some View {
        content
            .id(appState.currentActiveAccount?.id ?? 0)
            .onChange(of: flow) { [flow] _ in
                switch flow {
                case let .account(account):
                    if accountsTracker.savedAccounts.contains(account) {
                        accountsTracker.update(with: SavedAccount(from: account, lastUsed: .now))
                    }
                default:
                    break
                }
                flowDidChange()
            }
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
            var account = account
            siteInformation.myUserInfo = nil
            appState.setActiveAccount(account, saveChanges: false)
            siteInformation.load(account: account)
            favoriteCommunitiesTracker.configure(for: account)
            
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
    
    @MainActor
    private func setFlow(_ flow: AppFlow) {
        transition(flow)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.flow = flow
        }
    }
    
    /// This method changes the current application flow and places a _transition_ view across the active window while
    /// - Parameter newFlow: The `AppFlow` that the application should transition into
    private func transition(_ newFlow: AppFlow) {
        let transitionAccountName: String?
        switch newFlow {
        case let .account(account):
            transitionAccountName = account.nickname
        default:
            transitionAccountName = nil
        }
        
        Task { @MainActor in
            
            let transition = TransitionView(accountName: transitionAccountName)
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
