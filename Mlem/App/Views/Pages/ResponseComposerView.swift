//
//  ReplyView.swift
//  Mlem
//
//  Created by Sjmarf on 14/07/2024.
//

import MlemMiddleware
import SwiftUI

struct ResponseComposerView: View {
    let proxy: MarkdownTextEditorProxy = .init()
    
    @State var text: String = ""
    @FocusState var focused: Bool
    @State var presentationSelection: PresentationDetent = .large
    
    var body: some View {
        // No `ScrollView` here - `MarkdownTextEditor` (and the SwiftUI `TextEditor`) each have a built-in `ScrollView`.
        // We need to use that `ScrollView`, so that the view scrolls down automatically when the cursor goes behind the
        // keyboard. In iOS 17.4, there is a `UITextView.transfersVerticalScrollingToParent` property that we could maybe
        // use to retain the SwiftUI ScrollView if we want to

        //
        // Using `.toolbar` to do the keyboard toolbar doesn't work in sheets due to a bug in iOS 17.
        // Using UIKit instead.
        MarkdownTextEditor(text: $text, proxy: proxy) { keyboardToolbar }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
            .toolbar {
                Button("Send", systemImage: Icons.send) {}
            }
            .presentationDetents([.medium, .large], selection: $presentationSelection)
    }
    
    @ViewBuilder
    var keyboardToolbar: some View {
        ScrollView(.horizontal) {
            Spacer()
            HStack(spacing: 16) {
                // iPad already shows these buttons
                if !UIDevice.isPad {
                    keyboardButton("Undo", systemImage: "arrow.uturn.backward") { proxy.undo() }
                    keyboardButton("Redo", systemImage: "arrow.uturn.forward") { proxy.redo() }
                    Divider()
                }
                keyboardButton("Bold", systemImage: "bold") { print("BOLD") }
                keyboardButton("Italic", systemImage: "italic") {}
                keyboardButton("Strikethrough", systemImage: "strikethrough") {}
                keyboardButton("Heading", systemImage: "textformat.size") {}
                keyboardButton("Superscript", systemImage: "textformat.superscript") {}
                keyboardButton("Subscript", systemImage: "textformat.subscript") {}
                keyboardButton("Quote", systemImage: "quote.bubble") {}
                keyboardButton("Image", systemImage: "photo") {}
                keyboardButton("Spoiler", systemImage: "eye") {}
            }
            .padding(.horizontal)
            .padding(.bottom, 2)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }
    
    @ViewBuilder
    func keyboardButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: systemImage)
                    .imageScale(.large)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: 24)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .labelStyle(.iconOnly)
    }
}
