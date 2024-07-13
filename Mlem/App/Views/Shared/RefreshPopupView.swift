//
//  RefreshPopupView.swift
//  Mlem
//
//  Created by Sjmarf on 12/07/2024.
//

import SwiftUI

struct RefreshPopupView: View {
    @Environment(Palette.self) var palette
    
    let title: String
    @Binding var isPresented: Bool
    let callback: () -> Void
    
    init(_ title: String, isPresented: Binding<Bool>, callback: @escaping () -> Void) {
        self.title = title
        self._isPresented = isPresented
        self.callback = callback
    }
    
    var body: some View {
        Group {
            if isPresented {
                HStack(spacing: 0) {
                    Text(title)
                        .padding(.horizontal, 10)
                    Button {
                        isPresented = false
                        HapticManager.main.play(haptic: .lightSuccess, priority: .high)
                        Task { @MainActor in
                            callback()
                        }
                    } label: {
                        Label("Refresh", systemImage: Icons.refresh)
                            .foregroundStyle(palette.selectedInteractionBarItem)
                            .fontWeight(.semibold)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 10)
                            .background(palette.accent, in: .capsule)
                    }
                    .buttonStyle(.plain)
                }
                .padding(4)
                .background(palette.secondaryBackground, in: .capsule)
                .shadow(color: .black.opacity(0.1), radius: 5)
                .shadow(color: .black.opacity(0.1), radius: 1)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.bouncy, value: isPresented)
    }
}
