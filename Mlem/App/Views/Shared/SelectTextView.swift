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
        NavigationStack {
            textEditor(withBackground: false)
                .padding(.horizontal, 20)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        CloseButtonView()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        copyButton
                    }
                }
        }
        .presentationBackgroundInteraction(.enabled)
    }
    
    @ViewBuilder
    func textEditor(withBackground: Bool) -> some View {
        TextEditor(text: .constant(text))
            .scrollContentBackground(.hidden)
            .introspect(.textEditor, on: .iOS(.v26)) { textEditor in
                textEditor.isEditable = false
                textEditor.textContainerInset = .init(top: 0, left: 10, bottom: 10, right: 10)
                if withBackground {
                    textEditor.backgroundColor = UIColor(palette.background.primary)
                } else {
                    textEditor.backgroundColor = .clear
                }
            }
    }
    
    @ViewBuilder
    var copyButton: some View {
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
    }
}
