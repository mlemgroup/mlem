//
//  EmbeddingsSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-22.
//

import SwiftUI

struct EmbeddingSettingsView: View {
    @Setting(\.links_embedLoops) var embedLoops
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Embedded Content",
                description: "Display linked media from supported hosts in-app rather than as a link.",
                icon: .general.embedding
            )
            // TODO: use loops.video logo directly (hence why this is not in Icons)
            Toggle(String("loops.video"), systemImage: "repeat", isOn: $embedLoops)
        }
        .labelStyle(.conditional)
        .toggleStyle(.conditional)
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Embedded Content")
    }
}
