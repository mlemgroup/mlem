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
                title: "Interaction Bar",
                description: "Choose whether to use an alternate interaction bar layout for post and comment reports in Mod Mail."
            ) {
                Toggle("Use Alternate Layout", isOn: $useAlternateLayout)
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
