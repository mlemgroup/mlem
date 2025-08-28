//
//  AnimatedAvatarSettingsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-15.
//

import SwiftUI

struct AnimatedAvatarSettingsView: View {
    @Setting(\.media_animatedAvatars) var animatedAvatars
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Animated Avatars",
                description: "Some users set animated media as their avatar. Control whether these avatars should play their animations.",
                icon: .general.playCircle
            )
            .tint(.themedColorfulAccent(4))
            
            Picker("Animate Avatars...", selection: $animatedAvatars) {
                ForEach(AnimatedAvatarBehavior.allCases, id: \.self) { location in
                    Label(location.label.key, icon: location.icon)
                        .symbolVariant(.circle)
                        .tag(location)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
        .withConditionalLabelStyle()
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Animated Avatars")
    }
}
