//
//  JumpButton.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2023.
//

import SwiftUI
import Dependencies

struct JumpButtonView: View {
    @State private var pressed: Bool = false
    
    @Dependency(\.hapticManager) var hapticManager

    var onShortPress: () -> Void
    var onLongPress: () -> Void
    
    var body: some View {
        Button {} label: {
            Image(systemName: "chevron.down")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .aspectRatio(contentMode: .fit)
                .padding(16)
                .background(
                    Circle()
                        .stroke(.tertiary.opacity(0.3))
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                )
                .padding(10)
                .scaleEffect(self.pressed ? 1.2 : 1.0)
                .onTapGesture {
                    hapticManager.play(haptic: .gentleInfo, priority: .high)
                    onShortPress()
                }
                .onLongPressGesture(
                    perform: {
                        hapticManager.play(haptic: .gentleInfo, priority: .high)
                        onLongPress()
                    },
                    onPressingChanged: { pressing in
                        withAnimation(.interactiveSpring()) {
                            self.pressed = pressing
                        }
                    }
                )
        }
        .buttonStyle(EmptyButtonStyle())
        .padding(10)
    }
}
