//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var appState: AppState

    @State private var errorAlert: ErrorAlert?
    @State private var tabSelection = 1
    
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    
    var body: some View {
        TabView(selection: $tabSelection) {
            AccountsPage()
                .tabItem {
                    Label("Feeds", systemImage: "scroll")
                        .environment(\.symbolVariants, tabSelection == 1 ? .fill : .none)
                }.tag(1)
            
            if let currentActiveAccount = appState.currentActiveAccount {
                InboxView(account: currentActiveAccount)
                    .tabItem {
                        Label("Inbox", systemImage: "mail.stack")
                            .environment(\.symbolVariants, tabSelection == 2 ? .fill : .none)
                    }.tag(2)
                
                NavigationView {
                    ProfileView(account: currentActiveAccount)  
                } .tabItem {
                    Label(computeUsername(account: currentActiveAccount), systemImage: "person.circle")
                        .environment(\.symbolVariants, tabSelection == 3 ? .fill : .none)
                }.tag(3)
            }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                        .environment(\.symbolVariants, tabSelection == 4 ? .fill : .none)
                }.tag(4)
        }
        .onAppear {
            AppConstants.keychain["test"] = "I-am-a-saved-thing"
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
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
