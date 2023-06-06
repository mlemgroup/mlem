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
                Text(currentActiveAccount.username)
                    .tabItem {
                        Label("Messages", systemImage: "mail.stack")
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
    }
}
