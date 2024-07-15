//
//  MarkdownEditorToolbarView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import SwiftUI

struct MarkdownEditorToolbarView: View {
    let textView: UITextView
    
    var body: some View {
        ScrollView(.horizontal) {
            Spacer()
            HStack(spacing: 16) {
                // iPad already shows these buttons
                if !UIDevice.isPad {
                    Button("Undo", systemImage: "arrow.uturn.backward") {
                        textView.undoManager?.undo()
                    }
                    Button("Redo", systemImage: "arrow.uturn.forward") {
                        textView.undoManager?.redo()
                    }
                    Divider()
                }
                Button("Bold", systemImage: "bold") {
                    textView.wrapSelectionWithDelimiters("**")
                }
                Button("Italic", systemImage: "italic") {
                    textView.wrapSelectionWithDelimiters("*")
                }
                Button("Strikethrough", systemImage: "strikethrough") {
                    textView.wrapSelectionWithDelimiters("~~")
                }
                Button("Heading", systemImage: "textformat.size") {}
                Button("Superscript", systemImage: "textformat.superscript") {
                    textView.wrapSelectionWithDelimiters("^")
                }
                Button("Subscript", systemImage: "textformat.subscript") {
                    textView.wrapSelectionWithDelimiters("~")
                }
                
                // Potentially "chevron.left.chevron.right" is better, it's iOS 18+ though
                Button("Code", systemImage: "chevron.left.forwardslash.chevron.right") {
                    textView.wrapSelectionWithDelimiters("`")
                }
                Divider()
                Button("Image", systemImage: "photo") {}
                Button("Spoiler", systemImage: "eye") {
                    textView.wrapSelectionWithSpoiler()
                }
            }
            .imageScale(.large)
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .labelStyle(.iconOnly)
            .padding(.horizontal)
            .padding(.bottom, 2)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }
}
