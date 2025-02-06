//
//  ModMailInteractionBarSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-06.
//

import SwiftUI

struct ModMailInteractionBarSettingsView: View {
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Interaction Bar",
                description: "If you like, you can choose to use an alternate interaction bar layout for posts and comments in Mod Mail."
            ) {}
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
