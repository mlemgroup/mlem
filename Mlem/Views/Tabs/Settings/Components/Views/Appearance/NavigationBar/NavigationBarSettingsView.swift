//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 19/07/2023.
//

import SwiftUI

struct NavigationBarSettingsView: View {
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    @AppStorage("showTabNames") var showTabNames: Bool = true
    
    var body: some View {
        Form {
            Toggle("Show Labels", isOn: $showTabNames)
            Toggle("Show Username", isOn: $showUsernameInNavigationBar)
        }
        .navigationTitle("Navigation Bar")
    }
}
