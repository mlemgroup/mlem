//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ContentView: View
{    
    var body: some View
    {
        TabView
        {
            AccountsPage()
                .tabItem
                {
                    Label("Posts", systemImage: "text.bubble")
                }
            
            LoggedInUserPage()
                .tabItem {
                    Label("User", systemImage: "person.fill")
                }
            
            SettingsView()
                .tabItem
                {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear
        {}
    }
}
