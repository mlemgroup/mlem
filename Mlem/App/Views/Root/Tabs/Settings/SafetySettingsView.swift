//
//  SafetySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-24.
//

import SwiftUI
import Theming

struct SafetySettingsView: View {
    @Environment(FiltersTracker.self) var filtersTracker

    @Setting(\.safety_blurNsfw) var blurNsfw
    @Setting(\.filters_keywordFilterEnabled) var keywordFilterEnabled
    @Setting(\.safety_enableNsfwCommunityWarning) var showNsfwCommunityWarning
    @Setting(\.safety_enableModlogWarning) var showModlogWarning

    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Safety & Filtering",
                // swiftlint:disable:next line_length
                description: "Customize how content is displayed in your feed. Choose which types of content are blurred, and apply filters to hide posts from the feed altogether.",
                icon: .settings.safety
            )
            .gradientTint(.themedColorfulAccent(3))
            Section {
                NavigationLink(
                    "Blur NSFW Content",
                    value: .init(localized: blurNsfw.label),
                    fallbackValue: "",
                    icon: .settings.blurNsfw,
                    destination: .settings(.safetyBlurNsfw)
                )
                NavigationLink(
                    "Content Warnings",
                    value: String(localized: contentWarningsNavigationLinkValue),
                    fallbackValue: "",
                    icon: .general.warning,
                    destination: .settings(.safetyWarnings)
                )
            }
            Section {
                NavigationLink(
                    "Filters",
                    value: .init(localized: filtersNavigationLinkValue),
                    fallbackValue: "",
                    icon: .settings.keywordFilter,
                    destination: .settings(.filters)
                )
            }
        }
        .contentMargins(.top, 16)
        .withConditionalLabelStyle()
        .hiddenNavigationTitle("Safety & Filtering")
    }
    
    var contentWarningsNavigationLinkValue: LocalizedStringResource {
        switch (showNsfwCommunityWarning, showModlogWarning) {
        case (true, true): "All"
        case (true, false): "NSFW Communities"
        case (false, true): "Modlogs"
        case (false, false): "None"
        }
    }
    
    var filtersNavigationLinkValue: LocalizedStringResource {
        var sum = 0
        if filtersTracker.keywordFilterEnabled && !filtersTracker.rawKeywords.isEmpty { sum += 1 }
        if filtersTracker.literalFilterEnabled && !filtersTracker.literals.isEmpty { sum += 1 }
        return sum > 0 ? "\(sum) Active" : "None"
    }
}
