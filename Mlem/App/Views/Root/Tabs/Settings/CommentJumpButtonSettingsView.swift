//
//  CommentJumpButtonSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-22.
//

import SwiftUI

struct CommentJumpButtonSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Setting(\.jumpButton) var jumpButton
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Jump Button",
                description: "Tap on the Jump Button whilst viewing a comment thread to scroll to the next comment."
            ) {
                Image(icon: .lemmy.jumpButton)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.themedSecondary)
                    .aspectRatio(contentMode: .fill)
                    .padding(25)
                    .background(
                        Circle()
                            .stroke(.themedTertiary.opacity(0.3), lineWidth: 3)
                            .background(.ultraThinMaterial)
                            .clipShape(.circle)
                    )
                    .compositingGroup()
                    .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .clear, radius: 10, y: 5)
            }
            Section {
                Toggle(
                    "Jump Button",
                    systemImage: Icons.jumpButtonCircle,
                    isOn: .init(get: { jumpButton != .none }, set: { jumpButton = $0 ? .bottomTrailing : .none })
                )
            }
            if jumpButton != .none {
                Section("Alignment") {
                    Picker("Jump Button", selection: $jumpButton) {
                        ForEach(pickerCases, id: \.self) { location in
                            Label(String(localized: location.label), systemImage: location.systemImage)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
            }
        }
        .labelStyle(.conditional)
        .contentMargins(.top, 16)
        .animation(.easeOut(duration: 0.1), value: jumpButton == .none)
        .hiddenNavigationTitle("Jump Button")
    }
    
    var pickerCases: [CommentJumpButtonLocation] {
        [.bottomLeading, .bottomCenter, .bottomTrailing]
    }
}
