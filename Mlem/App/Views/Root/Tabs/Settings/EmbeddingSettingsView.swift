//
//  EmbeddingsSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-22.
//

import SwiftUI

struct EmbeddingSettingsView: View {
    @Setting(\.embedLoops) var embedLoops
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Embeddings",
                description: "Display linked media from supported hosts in-app rather than as a link."
            ) {
                // TODO: more descriptive image
                Image(systemName: Icons.embedding)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64)
                    .foregroundStyle(.tertiary)
                    .padding([.horizontal, .top], 20)
            }
            
            // TODO: use loops.video logo directly (hence why this is not in Icons)
            Toggle(String("loops.video"), systemImage: "repeat", isOn: $embedLoops)
        }
        .labelStyle(.conditional)
    }
}
