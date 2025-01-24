//
//  SafetySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-24.
//

import SwiftUI

struct SafetySettingsView: View {
    @Environment(Palette.self) var palette
    @Environment(FiltersTracker.self) var filtersTracker

    @Setting(\.blurNsfw) var blurNsfw
    @Setting(\.keywordFilterEnabled) var keywordFilterEnabled

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Safety & Filtering",
                // swiftlint:disable:next line_length
                description: "Customize how content is displayed in your feed. Choose which types of content are blurred, and apply filters to hide posts from the feed altogether.",
                systemImage: "shield.lefthalf.filled"
            )
            .tint(palette.colorfulAccent(3))
            Section {
                NavigationLink(
                    "Blur NSFW Content",
                    value: .init(localized: blurNsfw.label),
                    fallbackValue: "",
                    systemImage: Icons.blurNsfw,
                    destination: .settings(.safetyBlurNsfw)
                )
                NavigationLink(
                    "Content Warnings",
                    value: "All",
                    fallbackValue: "",
                    systemImage: Icons.warning,
                    destination: .settings(.safetyWarnings)
                )
            }
            Section {
                NavigationLink(
                    "Keyword Filters",
                    value: (keywordFilterEnabled && !filtersTracker.filteredKeywords.isEmpty) ? "On" : "Off",
                    fallbackValue: "",
                    systemImage: Icons.keywordFilter,
                    destination: .settings(.filters)
                )
            }
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
    }
}
