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
                    FancyTabBarLabel(symbolName: "scroll", text: "Feeds")
                        .contextMenu {
                            Button("hit me!") {
                                print("hit!")
                            }
                        }
                } labelActive: {
                    FancyTabBarLabel(symbolName: "scroll.fill", text: "Feeds", color: .accentColor)
                        .contextMenu {
                            Button("hit me!") {
                                print("hit!")
                            }
                        }
                }
            InboxView()
                .fancyTabItem(tag: 2) {
                    FancyTabBarLabel(tagHash: 2.hashValue, symbolName: "mail.stack", text: "Inbox")
                } labelActive: {
                    FancyTabBarLabel(tagHash: 2.hashValue, symbolName: "mail.stack.fill", text: "Inbox", color: .accentColor)
                }
            
            ProfileView(userID: appState.currentActiveAccount.id)
                .fancyTabItem(tag: 3) {
                    FancyTabBarLabel(symbolName: "person.circle", text: appState.currentActiveAccount.username)
                } labelActive: {
                    FancyTabBarLabel(symbolName: "person.circle.fill", text: appState.currentActiveAccount.username, color: .accentColor)
                }
            
            SearchView()
                .fancyTabItem(tag: 4) {
                    FancyTabBarLabel(symbolName: "magnifyingglass", text: "Search")
                } labelActive: {
                    FancyTabBarLabel(symbolName: "text.magnifyingglass", text: "Search", color: .accentColor)
                }
            
            SettingsView()
                .fancyTabItem(tag: 5) {
                    FancyTabBarLabel(symbolName: "gear", text: "Settings")
                } labelActive: {
                    FancyTabBarLabel(symbolName: "gear", text: "Settings", color: .accentColor)
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
