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
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker

    @StateObject var easterFlagsTracker: EasterFlagsTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()
    @StateObject var recentSearchesTracker: RecentSearchesTracker = .init()
    @StateObject var layoutWidgetTracker: LayoutWidgetTracker = .init()
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
        case let .reauth(account):
            appState.clearActiveAccount()
            accountsTracker.removeAccount(account: account)
        case let .account(account):
            print(account.lastLoggedInVersion)
            appState.setActiveAccount(account)
            favoriteCommunitiesTracker.configure(for: account)
            siteInformation.load { version in
                // TODO:
                // - save that the account has been version checked
                // - better transition screen
                let thresholdVersion = SiteVersion("0.19.0")
                if account.lastLoggedInVersion ?? .zero < thresholdVersion,
                   version >= thresholdVersion {
                    // swiftlint:disable line_length
                    print("site version \(version) over threshold \(thresholdVersion), account was last logged in to \(account.lastLoggedInVersion). reauthenticating.")
                    // swiftlint:enable line_length
                    setFlow(.reauth(account))
                }
            }
            
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
        case let .reauth(account):
            AddSavedInstanceView(onboarding: false, givenInstance: account.instanceLink.absoluteString, givenUsername: account.username)
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
        let transitionAccountName: String?
        switch newFlow {
        case .onboarding:
            transitionAccountName = nil
        case .reauth:
            transitionAccountName = nil
        case let .account(account):
            transitionAccountName = account.nickname
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
