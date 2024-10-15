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
                    Text("In-App").tag(false)
                    Text("In Default Browser").tag(true)
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            
            Section {
                Toggle("Open in Reader", isOn: $openLinksInReaderMode)
                    .disabled(openLinksInBrowser)
            } footer: {
                Text("Automatically enable Reader for supported webpages. You can only enable this when using the in-app browser.")
            }
            
            Section {
                Toggle(
                    "Tappable Links",
                    isOn: Binding(
                        get: { tappableLinksDisplayMode != .disabled },
                        set: { newValue in
                            withAnimation(.easeOut(duration: 0.1)) {
                                tappableLinksDisplayMode = newValue ? .large : .disabled
                            }
                        }
                    )
                )
                if compactComments {
                    Picker("Show Full URL", selection: $tappableLinksDisplayMode) {
                        Text("Always").tag(TappableLinksDisplayMode.large)
                        Text("Never").tag(TappableLinksDisplayMode.compact)
                        Text("Never in Comments").tag(TappableLinksDisplayMode.contextual)
                    }
                    .pickerStyle(.menu)
                } else {
                    if tappableLinksDisplayMode != .disabled {
                        Toggle(
                            "Show Full URL",
                            isOn: Binding(
                                get: { tappableLinksDisplayMode != .compact },
                                set: { tappableLinksDisplayMode = $0 ? .large : .compact }
                            )
                        )
                    }
                }
            }
        }
        .navigationTitle("Links")
    }
}
