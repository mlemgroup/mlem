//
//  ModMailInteractionBarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-06.
//

import SwiftUI

struct ModMailInteractionBarSettingsView: View {
    @Setting(\.alternateInteractionBarLayoutForReports) var useAlternateLayout
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Mod Mail Interaction Bar",
                description: "Choose whether to use an alternate interaction bar layout for post and comment reports in Mod Mail."
            ) {}
            Section {
                Toggle("Use Alternate Layout", isOn: $useAlternateLayout)
            }
            if useAlternateLayout {
                Section {
                    NavigationLink(.settings(.postReportInteractionBar)) {
                        SettingsInteractionBarSummaryView(
                            title: "Post Reports",
                            configuration: InteractionBarTracker.main.postReportInteractionBar
                        )
                    }
                    NavigationLink(.settings(.commentReportInteractionBar)) {
                        SettingsInteractionBarSummaryView(
                            title: "Comment Reports",
                            configuration: InteractionBarTracker.main.commentReportInteractionBar
                        )
                    }
                }
            }
        }
        .animation(.easeOut(duration: 0.1), value: useAlternateLayout)
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
