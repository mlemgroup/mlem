//
//  ExternalLinkSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-28.
//

import SwiftUI

struct ExternalLinkSettingsView: View {
    @Setting(\.links_openInBrowser) var openLinksInBrowser
    @Setting(\.links_readerMode) var openLinksInReaderMode
    
    var body: some View {
        Form {
            Section("Open External Links") {
                Picker("Open External Links", selection: $openLinksInBrowser) {
                    Label("In Mlem", icon: .settings.inApp).tag(false)
                    Label("In Default Browser", icon: .general.browser).tag(true)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section {
                Toggle("Open in Reader", icon: .settings.reader, isOn: $openLinksInReaderMode)
                    .disabled(openLinksInBrowser)
            } footer: {
                Text("Automatically enable Reader for supported webpages. You can only enable this when using the in-app browser.")
            }
        }
        .navigationTitle("External Links")
        .labelStyle(.conditional)
        .toggleStyle(.conditional)
    }
}
