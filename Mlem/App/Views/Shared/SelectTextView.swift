//
//  SelectTextView.swift
//  Mlem
//
//  Created by Sjmarf on 03/03/2024.
//

import ComponentViews
import Dependencies
import Haptics
import SwiftUI
import SwiftUIIntrospect

struct SelectTextView: View {
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.palette) var palette
    
    let text: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = text
                    hapticManager.play(haptic: .lightSuccess, tier: .high)
                    dismiss()
                } label: {
                    Label("Copy All", icon: .general.copy)
                        .symbolVariant(.fill)
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(height: 30)
                .padding(.horizontal, 12)
                .background(Capsule().fill(.themedAccent))
                CloseButtonView()
            }
            .padding(.horizontal, 10)
            TextEditor(text: .constant(text))
                .introspect(.textEditor, on: .iOS(.v17, .v18)) { textEditor in
                    textEditor.isEditable = false
                    textEditor.textContainerInset = .init(top: 0, left: 10, bottom: 10, right: 10)
                    textEditor.backgroundColor = UIColor(palette.background.primary)
                }
        }
        .padding(.top, 10)
        .presentationDetents([.medium])
        .presentationBackgroundInteraction(.enabled)
        .presentationCornerRadius(20)
        .background(.themedBackground)
    }
}
