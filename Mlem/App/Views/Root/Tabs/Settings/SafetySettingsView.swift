//
//  SafetySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-24.
//

import SwiftUI

struct SafetySettingsView: View {
    @Environment(Palette.self) var palette
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Safety & Filtering",
                // swiftlint:disable:next line_length
                description: "Customize how content is displayed in your feed. Choose which types of content are blurred, and apply filters to hide posts from the feed altogether."
            ) {
                Image(systemName: "shield.lefthalf.filled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
                    .foregroundStyle(palette.colorfulAccent(3))
            }
            Section {
                NavigationLink(
                    "Blur NSFW Content",
                    value: "Always",
                    fallbackValue: "",
                    destination: .settings(.general)
                )
                NavigationLink(
                    "Content Warnings",
                    value: "All",
                    fallbackValue: "",
                    destination: .settings(.general)
                )
            }
            Section {
                NavigationLink(
                    "Keyword Filters",
                    value: "Enabled",
                    fallbackValue: "",
                    destination: .settings(.general)
                )
            }
        }
        .contentMargins(.top, 16)
    }
}
