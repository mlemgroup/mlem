//
//  AdvancedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct AdvancedSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink("Cache", destination: .settings(.cache))
                NavigationLink("Error Log", destination: .settings(.errorLog))
                NavigationLink("Error Notification Timeout", destination: .settings(.errorToastTimeout))
            }
            Section {
                NavigationLink("Developer", destination: .settings(.developer))
            }
        }
        .navigationTitle("Advanced")
    }
}
