//
//  AdvancedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct AdvancedSettingsView: View {
    @Setting(\.dev_developerMode) var developerMode

    var body: some View {
        Form {
            Section {
                NavigationLink("Cache", destination: .settings(.cache))
                NavigationLink("Error Log", destination: .settings(.errorLog))
                NavigationLink("Error Notification Timeout", destination: .settings(.errorToastTimeout))
            }
            Section {
                Section {
                    Toggle("Developer Mode", isOn: $developerMode)
                }

                NavigationLink("Developer", destination: .settings(.developer))
            }
        }
        .navigationTitle("Advanced")
    }
}
