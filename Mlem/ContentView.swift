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
    var body: some View
    {
        TabView
        {
            Posts_View()
                .tabItem
                {
                    Image(systemName: "text.bubble")
                    Text("Posts")
                }
            Settings_View()
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
