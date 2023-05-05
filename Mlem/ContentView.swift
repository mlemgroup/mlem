//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import CoreData
import SwiftUI

struct ContentView: View
{
    
    @StateObject var appState: AppState = AppState()
    
    var body: some View
    {
        TabView
        {
            InstanceCommunityListView()
                .tabItem
                {
                    Image(systemName: "text.bubble")
                    Text("Posts")
                }
                .environmentObject(appState)
            
            SettingsView()
                .tabItem
                {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .onAppear
        {}
    }
}
