//
//  ExperimentalSettingsView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-04.
//

import SwiftUI

struct ExperimentalSettingsView: View {
    var body: some View {
        List {
            Section {
                Toggle(isOn: .constant(false), label: {
                    Text("Use Experimental Settings")
                })
            } header: {
                EmptyView()
            } footer: {
                // swiftlint:disable line_length
                Text("Experimental Settings only apply to development and beta builds. These settings allow developers to quickly iterate on features and test users to experiment with values to their liking before providing feedback")
                // swiftlint:enable line_length
            }
        }
        .navigationTitle("Experimental Settings")
    }
}
