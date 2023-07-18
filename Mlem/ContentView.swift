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
    
    @State private var tabSelection: Int = 1
    
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    
    var body: some View {
        FancyTabBar(selection: $tabSelection) {
            FeedRoot()
                .fancyTabItem(tag: 1) {
                    AnyView(VStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: tabSelection == 1 ? "scroll.fill" : "scroll")
                        
                        Text("Feeds")
                    })
                } labelActive: {
                    AnyView(Text("active"))
                }
            InboxView()
                .fancyTabItem(tag: 2) {
                    Label("Inbox", systemImage: "mail.stack")
                        .environment(\.symbolVariants, tabSelection == 2 ? .fill : .none)
                } labelActive: {
                    Label("Inbox", systemImage: "mail.stack")
                        .environment(\.symbolVariants, tabSelection == 2 ? .fill : .none)
                }
            
            ProfileView(userID: appState.currentActiveAccount.id)
                .fancyTabItem(tag: 3) {
                    Label(computeUsername(account: appState.currentActiveAccount), systemImage: "person.circle")
                        .environment(\.symbolVariants, tabSelection == 3 ? .fill : .none)
                } labelActive: {
                    Label(computeUsername(account: appState.currentActiveAccount), systemImage: "person.circle")
                        .environment(\.symbolVariants, tabSelection == 3 ? .fill : .none)
                }
            
            SearchView()
                .fancyTabItem(tag: 4) {
                    Label("Search", systemImage: tabSelection == 4 ? "text.magnifyingglass" : "magnifyingglass")
                } labelActive: {
                    Label("Search", systemImage: tabSelection == 4 ? "text.magnifyingglass" : "magnifyingglass")
                }
            
            SettingsView()
                .fancyTabItem(tag: 5) {
                    Label("Settings", systemImage: "gear")
                        .environment(\.symbolVariants, tabSelection == 5 ? .fill : .none)
                } labelActive: {
                    Label("Settings", systemImage: "gear")
                        .environment(\.symbolVariants, tabSelection == 5 ? .fill : .none)
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
