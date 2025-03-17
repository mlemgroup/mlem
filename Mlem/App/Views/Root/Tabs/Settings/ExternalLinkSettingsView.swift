//
//  ExternalLinkSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-28.
//

import SwiftUI

struct ExternalLinkSettingsView: View {
    @Setting(\.openLinksInBrowser) var openLinksInBrowser
    @Setting(\.openLinksInReaderMode) var openLinksInReaderMode
    
    var body: some View {
        Form {
            Section("Open External Links") {
                Picker("Open External Links", selection: $openLinksInBrowser) {
                    Label("In Mlem", systemImage: Icons.inApp).tag(false)
                    Label("In Default Browser", systemImage: Icons.browser).tag(true)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section {
                Toggle("Open in Reader", systemImage: Icons.reader, isOn: $openLinksInReaderMode)
                    .disabled(openLinksInBrowser)
            } footer: {
                Text("Automatically enable Reader for supported webpages. You can only enable this when using the in-app browser.")
            }
        }
        .navigationTitle("External Links")
        .labelStyle(.conditional)
    }
}
