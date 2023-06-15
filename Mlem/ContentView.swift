//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View
{
    
    @EnvironmentObject var appState: AppState
    
    @State private var errorAlert: ErrorAlert?
    
    var body: some View
    {
        TabView
        {
            AccountsPage()
                .tabItem
                {
                    Label("Feeds", systemImage: "text.bubble")
                }
            
            if let currentActiveAccount = appState.currentActiveAccount
            {
                Text("\(currentActiveAccount.username): \(currentActiveAccount.id)")
                    .tabItem {
                        Label("Messages", systemImage: "mail.stack")
                    }
                
                UserView(userID: currentActiveAccount.id, account: currentActiveAccount)
                    .tabItem {
                        Label(currentActiveAccount.username, systemImage: "person")
                    }
            }
            
            SettingsView()
                .tabItem
                {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear
        {
            AppConstants.keychain["test"] = "I-am-a-saved-thing"
        }
        .alert(using: $errorAlert) { content in
            Alert(title: Text(content.title), message: Text(content.message))
        }
        .environment(\.openURL, OpenURLAction(handler: didReceiveURL))
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
