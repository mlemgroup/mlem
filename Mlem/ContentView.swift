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
        .environment(\.openURL, OpenURLAction(handler: URLHandler.handle))
    }
}
