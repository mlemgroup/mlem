//
//  LinkSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 27/06/2024.
//

import SwiftUI

struct LinkSettingsView: View {
    @Setting(\.openLinksInBrowser) var openLinksInBrowser
    @Setting(\.openLinksInReaderMode) var openLinksInReaderMode
    @Setting(\.compactComments) var compactComments
    @Setting(\.tappableLinksDisplayMode) var tappableLinksDisplayMode
    
    var body: some View {
        Form {
            Section("Open External Links") {
                Picker("Open External Links", selection: $openLinksInBrowser) {
                    Label("In-App", systemImage: Icons.inApp).tag(false)
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
            
            Section {
                Toggle(
                    "Tappable Links",
                    systemImage: Icons.websiteAddress,
                    isOn: Binding(
                        get: { tappableLinksDisplayMode != .disabled },
                        set: { newValue in
                            withAnimation(.easeOut(duration: 0.1)) {
                                tappableLinksDisplayMode = newValue ? .large : .disabled
                            }
                        }
                    )
                )
                if tappableLinksDisplayMode != .disabled {
                    Picker("Show Full URL", systemImage: Icons.inlineCode, selection: $tappableLinksDisplayMode) {
                        Text("Automatic").tag(TappableLinksDisplayMode.contextual)
                        Text("Always").tag(TappableLinksDisplayMode.large)
                        Text("Never").tag(TappableLinksDisplayMode.compact)
                    }
                    .pickerStyle(.menu)
                }
            } footer: {
                if tappableLinksDisplayMode != .disabled {
                    Text("If set to \"Automatic\", the full URL will be hidden in compact comments.")
                }
            }
        }
        .labelStyle(.conditional)
        .navigationTitle("Links")
    }
}
