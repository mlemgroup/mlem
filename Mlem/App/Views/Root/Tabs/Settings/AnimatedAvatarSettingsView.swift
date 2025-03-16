//
//  AnimatedAvatarSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-15.
//

import SwiftUI

struct AnimatedAvatarSettingsView: View {
    @Setting(\.animatedAvatars) var animatedAvatars
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Animated Avatars",
                description: "Some users set animated media as their avatar. Control whether these avatars should play their animations.",
                systemImage: Icons.playCircle
            )
            .tint(.themedColorfulAccent(4))
            
            Picker("Animate Avatars...", selection: $animatedAvatars) {
                ForEach(AnimatedAvatarBehavior.allCases, id: \.self) { location in
                    Label(String(localized: location.label), systemImage: location.systemImage)
                        .tag(location)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
    }
}
