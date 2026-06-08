//
//  TapFriendlyLinksSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-28.
//

import SwiftUI

struct TapFriendlyLinksSettingsView: View {
    @Setting(\.links_displayMode) var tapFriendlyLinksDisplayMode
    
    var body: some View {
        Form {
            Section {
                Toggle(
                    "Tap-Friendly Links",
                    icon: .settings.tapFriendlyLinks,
                    isOn: Binding(
                        get: { tapFriendlyLinksDisplayMode != .disabled },
                        set: { newValue in
                            withAnimation(.easeOut(duration: 0.1)) {
                                tapFriendlyLinksDisplayMode = newValue ? .large : .disabled
                            }
                        }
                    )
                )
            }
            if tapFriendlyLinksDisplayMode != .disabled {
                Section("Show Full URL") {
                    Picker("Show Full URL", icon: .markdown.inlineCode, selection: $tapFriendlyLinksDisplayMode) {
                        Text("Automatic").tag(TapFriendlyLinksDisplayMode.contextual)
                        Text("Always").tag(TapFriendlyLinksDisplayMode.large)
                        Text("Never").tag(TapFriendlyLinksDisplayMode.compact)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } footer: {
                    if tapFriendlyLinksDisplayMode != .disabled {
                        Text("If set to \"Automatic\", the full URL will be hidden in compact comments.")
                    }
                }
            }
        }
        .navigationTitle("Tap-Friendly Links")
        .withConditionalLabelStyle()
    }
}
