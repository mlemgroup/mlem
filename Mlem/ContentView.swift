//
//  ContentView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            Posts_View()
                .tabItem{
                    Image(systemName: "text.bubble")
                    Text("Posts")
                }
            Settings_View()
                .tabItem{
                    Image(systemName: "gear")
                    Text("Settings")
              }
        }
        .onAppear {
            establishConnectionToLemmyInstance(instanceURL: "hexbear.net")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
