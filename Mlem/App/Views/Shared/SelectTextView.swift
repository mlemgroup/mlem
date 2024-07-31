//
//  SelectTextView.swift
//  Mlem
//
//  Created by Sjmarf on 03/03/2024.
//

import Dependencies
import SwiftUI
import SwiftUIIntrospect

struct SelectTextView: View {
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let text: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = text
                    HapticManager.main.play(haptic: .lightSuccess, priority: .high)
                    dismiss()
                } label: {
                    Label("Copy All", systemImage: Icons.copyFill)
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(height: 30)
                .padding(.horizontal, 12)
                .background(Capsule().fill(palette.accent))
                CloseButtonView()
            }
            .padding(.horizontal, 10)
            TextEditor(text: .constant(text))
                .introspect(.textEditor, on: .iOS(.v17, .v18)) { textEditor in
                    textEditor.isEditable = false
                    textEditor.textContainerInset = .init(top: 0, left: 10, bottom: 10, right: 10)
                }
        }
        .padding(.top, 10)
        .presentationDetents([.medium])
        .presentationBackgroundInteraction(.enabled)
    }
}
