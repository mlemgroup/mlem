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
    
    @State private var tabSelection = 1

    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true

    var body: some View {
        TabView(selection: $tabSelection) {
            FeedRoot()
                .tabItem {
                    Label("Feeds", systemImage: "scroll")
                        .environment(\.symbolVariants, tabSelection == 1 ? .fill : .none)
                }.tag(1)
            
            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "mail.stack")
                        .environment(\.symbolVariants, tabSelection == 2 ? .fill : .none)
                }.tag(2)
            
            NavigationView {
                ProfileView(userID: appState.currentActiveAccount.id)
            } .tabItem {
                Label(computeUsername(account: appState.currentActiveAccount), systemImage: "person.circle")
                    .environment(\.symbolVariants, tabSelection == 3 ? .fill : .none)
            }.tag(3)
            
            NavigationView {
                SearchView()
            } .tabItem {
                Label("Search", systemImage: tabSelection == 4 ? "text.magnifyingglass" : "magnifyingglass")
            }.tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                        .environment(\.symbolVariants, tabSelection == 5 ? .fill : .none)
                }.tag(5)
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
