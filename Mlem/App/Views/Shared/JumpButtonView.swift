//
//  JumpButton.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2023.
//

import SwiftUI

struct JumpButtonView: View {
    @State private var pressed: Bool = false
    
    var systemImage: String = Icons.jumpButton
    var onShortPress: () -> Void
    var onLongPress: (() -> Void)?
    
    var body: some View {
        Button {} label: {
            Image(systemName: systemImage)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .stroke(.tertiary.opacity(0.3))
                        .background(.bar)
                        .clipShape(.circle)
                )
                .padding(10)
                .scaleEffect(pressed ? 1.2 : 1.0)
                .onTapGesture {
                    HapticManager.main.play(haptic: .gentleInfo, priority: .high)
                    onShortPress()
                }
                .onLongPressGesture(
                    perform: {
                        HapticManager.main.play(haptic: .gentleInfo, priority: .high)
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
        .buttonStyle(.empty)
    }
}
