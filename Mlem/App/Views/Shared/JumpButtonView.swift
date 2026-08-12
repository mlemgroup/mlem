//
//  JumpButton.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2023.
//

import Haptics
import Icons
import SwiftUI

struct JumpButtonView: View {
    @Environment(HapticManager.self) var hapticManager
    
    @State private var pressed: Bool = false
    
    var icon: Icon = .lemmy.jumpButton
    var onShortPress: () -> Void
    var onLongPress: (() -> Void)?
    
    var body: some View {
        // using glassEffect rather than GlassButtonStyle because the button style is buggy
        content
            .tint(.primary)
            .glassEffect(.regular.interactive(), in: .circle)
            .padding(10)
    }
    
    var content: some View {
        Button {} label: {
            Image(icon: icon)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .padding(0)
                .scaleEffect(pressed ? 1.2 : 1.0)
                .onTapGesture {
                    hapticManager.play(haptic: .gentleInfo, tier: .high)
                    onShortPress()
                }
                .onLongPressGesture(
                    perform: {
                        hapticManager.play(haptic: .gentleInfo, tier: .high)
                        if let onLongPress {
                            onLongPress()
                        }
                    },
                    onPressingChanged: { pressing in
                        withAnimation(.interactiveSpring()) {
                            pressed = pressing
                        }
                    }
                )
        }
    }
}
