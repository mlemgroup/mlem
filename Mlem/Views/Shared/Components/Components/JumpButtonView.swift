//
//  JumpButton.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2023.
//

import SwiftUI

struct JumpButtonView: View {
    @State private var pressed: Bool = false

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
                    ZStack {
                        Circle()
                            .fill(Material.thinMaterial)

                        Circle()
                            .strokeBorder(.tertiary.opacity(0.3), lineWidth: 1)
                    }
                )
                .padding(10)
                .scaleEffect(self.pressed ? 1.2 : 1.0)
                .onTapGesture {
                    HapticManager.shared.play(haptic: .gentleInfo)
                    onShortPress()
                }
                .onLongPressGesture(
                    perform: {
                        HapticManager.shared.play(haptic: .gentleInfo)
                        onLongPress()
                    },
                    onPressingChanged: { pressing in
                        withAnimation(.bouncy) {
                            self.pressed = pressing
                        }
                    }
                )
        }
        .buttonStyle(EmptyButtonStyle())
        .padding(10)
    }
}
