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
    
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    
    var body: some View {
        FancyTabBar(selection: $tabSelection) {
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
                                     customText: computeUsername(account: appState.currentActiveAccount),
                                     symbolName: "person.circle",
                                     activeSymbolName: "person.circle.fill")
                    .contextMenu {
                        ForEach(accountsTracker.savedAccounts) { account in
                            Button(account.fullName()) {
                                // new accounts always go to the Feeds tab, so set that immediately
                                tabSelection = .feeds
                                // fake loading to smooth the transition
                                showLoading = true
                                // this delay makes sure the appState isn't updated until after the animation is finished, since that causes an ugly little duplication of the account item
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                                    // appState change should trigger re-eval of state and reset showLoading, but just in case
                                    defer { showLoading = false }
                                    appState.setActiveAccount(account)
                                }
                            }
                            .disabled(appState.currentActiveAccount == account)
                        }
                    }
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
        .onChange(of: appState.contextualError) { handle($0) }
        .onChange(of: appState.currentActiveAccount) { _ in
            print("yo")
        }
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
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
        .environmentObject(appState)
    }
    
    // MARK: helpers
    func computeUsername(account: SavedAccount) -> String {
        return showUsernameInNavigationBar ? account.username : "Profile"
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
