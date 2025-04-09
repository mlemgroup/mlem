//
//  ModMailInteractionBarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-06.
//

import SwiftUI

struct ModMailInteractionBarSettingsView: View {
    @Setting(\.interactionBar_alternateReportLayout) var useAlternateLayout
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Mod Mail Action Layouts",
                // swiftlint:disable:next line_length
                description: "Choose whether to use alternate interaction bar and swipe action layouts for post and comment reports in Mod Mail."
            ) {}
            Section {
                Toggle("Use Alternate Layouts", isOn: $useAlternateLayout)
            }
            if useAlternateLayout {
                Section("Posts") {
                    NavigationLink(.settings(.interactionBar(.postReport))) {
                        SettingsInteractionBarSummaryView(
                            title: "Interaction Bar",
                            configuration: InteractionBarTracker.main.postReportInteractionBar
                        )
                    }
                    NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.postReport)))
                }
                Section("Comments") {
                    NavigationLink(.settings(.interactionBar(.commentReport))) {
                        SettingsInteractionBarSummaryView(
                            title: "Interaction Bar",
                            configuration: InteractionBarTracker.main.commentReportInteractionBar
                        )
                    }
                    NavigationLink("Swipe Actions", destination: .settings(.swipeActions(.commentReport)))
                }
            }
        }
        .animation(.easeOut(duration: 0.1), value: useAlternateLayout)
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Mod Mail Action Layouts")
    }
}
