//
//  TappableLinksSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-28.
//

import SwiftUI

struct TappableLinksSettingsView: View {
    @Setting(\.links_displayMode) var tappableLinksDisplayMode
    
    var body: some View {
        Form {
            Section {
                Toggle(
                    "Tappable Links",
                    icon: .settings.tappableLinks,
                    isOn: Binding(
                        get: { tappableLinksDisplayMode != .disabled },
                        set: { newValue in
                            withAnimation(.easeOut(duration: 0.1)) {
                                tappableLinksDisplayMode = newValue ? .large : .disabled
                            }
                        }
                    )
                )
            }
            if tappableLinksDisplayMode != .disabled {
                Section("Show Full URL") {
                    Picker("Show Full URL", icon: .markdown.inlineCode, selection: $tappableLinksDisplayMode) {
                        Text("Automatic").tag(TappableLinksDisplayMode.contextual)
                        Text("Always").tag(TappableLinksDisplayMode.large)
                        Text("Never").tag(TappableLinksDisplayMode.compact)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } footer: {
                    if tappableLinksDisplayMode != .disabled {
                        Text("If set to \"Automatic\", the full URL will be hidden in compact comments.")
                    }
                }
            }
        }
        .navigationTitle("Tappable Links")
        .labelStyle(.conditional)
        .toggleStyle(.conditional)
    }
}
