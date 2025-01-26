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
    @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
    @Setting(\.showModlogWarning) var showModlogWarning

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
                    value: String(localized: contentWarningsNavigationLinkValue),
                    fallbackValue: "",
                    systemImage: Icons.warning,
                    destination: .settings(.safetyWarnings)
                )
            }
            Section {
                NavigationLink(
                    "Keyword Filters",
                    value: .init(localized: keywordFiltersNavigationLinkValue),
                    fallbackValue: "",
                    systemImage: Icons.keywordFilter,
                    destination: .settings(.filters)
                )
            }
        }
        .contentMargins(.top, 16)
        .labelStyle(.conditional)
    }
    
    var contentWarningsNavigationLinkValue: LocalizedStringResource {
        switch (showNsfwCommunityWarning, showModlogWarning) {
        case (true, true): "All"
        case (true, false): "NSFW Communities"
        case (false, true): "Modlogs"
        case (false, false): "None"
        }
    }
    
    var keywordFiltersNavigationLinkValue: LocalizedStringResource {
        if filtersTracker.filteredKeywords.isEmpty { return "None" }
        return keywordFilterEnabled ? "On" : "Off"
    }
}
