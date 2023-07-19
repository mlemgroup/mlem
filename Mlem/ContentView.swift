//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    
    @State private var errorAlert: ErrorAlert?
    @State private var expiredSessionAccount: SavedAccount?
    
    // tabs
    @State private var tabSelection: TabSelection = .feeds
    @State private var showLoading: Bool = false
    @GestureState private var isDetectingLongPress = false
    
    @State private var isPresentingAccountSwitcher: Bool = false
    
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    
    var body: some View {
        FancyTabBar(selection: $tabSelection, dragUpGestureCallback: showAccountSwitcher) {
            Group {
                FeedRoot(showLoading: showLoading)
                    .fancyTabItem(tag: TabSelection.feeds) {
                        FancyTabBarLabel(tag: TabSelection.feeds,
                                         symbolName: "scroll",
                                         activeSymbolName: "scroll.fill")
                    }
                InboxView()
                    .fancyTabItem(tag: TabSelection.inbox) {
                        FancyTabBarLabel(tag: TabSelection.inbox,
                                         symbolName: "mail.stack",
                                         activeSymbolName: "mail.stack.fill")
                    }
                
                ProfileView(userID: appState.currentActiveAccount.id)
                    .fancyTabItem(tag: TabSelection.profile) {
                        FancyTabBarLabel(tag: TabSelection.profile,
                                         customText: appState.currentActiveAccount.username,
                                         symbolName: "person.circle",
                                         activeSymbolName: "person.circle.fill")
                        .simultaneousGesture(accountSwitchLongPress)
                    }
                SearchView()
                    .fancyTabItem(tag: TabSelection.search) {
                        FancyTabBarLabel(tag: TabSelection.search,
                                         symbolName: "magnifyingglass",
                                         activeSymbolName: "text.magnifyingglass")
                    }
                
                SettingsView()
                    .fancyTabItem(tag: TabSelection.settings) {
                        FancyTabBarLabel(tag: TabSelection.settings,
                                         symbolName: "gear")
                    }
            }
        }
        .onChange(of: appState.contextualError) { handle($0) }
        .alert(using: $errorAlert) { content in
            Alert(
                title: Text(content.title),
                message: Text(content.message),
                dismissButton: .default(
                    Text("OK"),
                    action: { errorAlert = nil }
                )
            )
        }
        .sheet(item: $expiredSessionAccount) { account in
            TokenRefreshView(account: account) { updatedAccount in
                appState.setActiveAccount(updatedAccount)
            }
        }
        .sheet(isPresented: $isPresentingAccountSwitcher) {
            AccountsPage()
                .presentationDetents([.medium, .large])
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(appState)
    }
    
    // MARK: helpers
    func computeUsername(account: SavedAccount) -> String {
        return showUsernameInNavigationBar ? account.username : "Profile"
    }
    
    func showAccountSwitcher() {
        isPresentingAccountSwitcher = true
    }
    
    var accountSwitchLongPress: some Gesture {
        LongPressGesture()
            .onEnded { _ in
                // disable long press in accessibility mode to prevent conflict with HUD
                if !UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory {
                    isPresentingAccountSwitcher = true
                }
            }
    }
}

// MARK: - URL Handling

extension ContentView {
    func didReceiveURL(_ url: URL) -> OpenURLAction.Result {
        let outcome = URLHandler.handle(url)
        
        switch outcome.action {
        case let .error(message):
            errorAlert = .init(
                title: "Unsupported link",
                message: message
            )
        default:
            break
        }
        
        return outcome.result
    }
}

// MARK: - Error handling

extension ContentView {
    func handle(_ contextualError: ContextualError?) {
        guard let contextualError else {
            return
        }
        
#if DEBUG
        print("☠️ ERROR ☠️")
        print("🕵️ -> \(contextualError.underlyingError.description)")
        print("📝 -> \(contextualError.underlyingError.localizedDescription)")
#endif
        
        defer {
            // ensure we clear our the error once we've handled it...
            appState.contextualError = nil
        }
        
        if let clientError = contextualError.underlyingError.base as? APIClientError {
            switch clientError {
            case .invalidSession:
                expiredSessionAccount = appState.currentActiveAccount
                return
            case let .response(apiError, _):
                errorAlert = .init(title: "Error", message: apiError.error)
            default:
                break
            }
        }
        
        let title = contextualError.title ?? ""
        let message = contextualError.message ?? ""
        
        guard !title.isEmpty || !message.isEmpty else {
            // no title or message was supplied so don't notify the user of this...
            return
        }
        
        errorAlert = .init(title: title, message: message)
    }
}
