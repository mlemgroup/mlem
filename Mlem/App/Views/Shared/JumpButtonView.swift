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
        if #available(iOS 26, *) {
            // using glassEffect rather than GlassButtonStyle because the button style is buggy
            content
                .tint(.primary)
                .glassEffect(.regular.interactive(), in: .circle)
                .padding(10)
        } else {
            content
                .buttonStyle(.empty)
        }
    }
    
    var content: some View {
        Button {} label: {
            Image(icon: icon)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .background {
                    if !UIDevice.isIos26 {
                        Circle()
                            .stroke(.tertiary.opacity(0.3))
                            .background(.bar)
                            .clipShape(.circle)
                    }
                }
                .padding(UIDevice.isIos26 ? 0 : 10)
                .scaleEffect(pressed && !UIDevice.isIos26 ? 1.2 : 1.0)
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
