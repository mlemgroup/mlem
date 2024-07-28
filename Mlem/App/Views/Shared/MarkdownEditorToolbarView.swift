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
                Button("Bold", systemImage: Icons.bold) {
                    textView.wrapSelectionWithDelimiters("**")
                }
                Button("Italic", systemImage: Icons.italic) {
                    textView.wrapSelectionWithDelimiters("_")
                }
                Button("Strikethrough", systemImage: Icons.strikethrough) {
                    textView.wrapSelectionWithDelimiters("~~")
                }
                Button("Superscript", systemImage: Icons.superscript) {
                    textView.wrapSelectionWithDelimiters("^")
                }
                Button("Subscript", systemImage: Icons.subscript) {
                    textView.wrapSelectionWithDelimiters("~")
                }
                Button("Code", systemImage: Icons.inlineCode) {
                    textView.wrapSelectionWithDelimiters("`")
                }
                Divider()
                Button("Quote", systemImage: Icons.quote) {
                    textView.toggleQuoteAtCursor()
                }
                Button("Image", systemImage: Icons.uploadImage) {}
                Button("Spoiler", systemImage: Icons.spoiler) {
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