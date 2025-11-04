//
//  LinkEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-04.
//  

import SwiftUI

struct LinkEditorView: View {
    let close: () -> Void
    
    @State var urlString: String = "Hello world"
    
    @FocusState var focused: Bool

    @ScaledMetric(relativeTo: .body) var bodyHeight = 40

    var attributedStringBinding: Binding<AttributedString> {
        .init {
            var string = AttributedString(urlString)
            string.foregroundColor = .red
            return string
        } set: { 
            urlString = String($0.characters)
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Button("Go back", icon: .general.backward) {
                    focused = false
                    close()
                }
                Spacer()
            }
            .buttonStyle(OverlayButtonStyle())
            textEditor
                .padding(.horizontal, 5)
        }
        .padding(Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    var textEditor: some View {
        if #available(iOS 26.0, *) {
            TextEditor(text: attributedStringBinding)
                .focused($focused)
                .onAppear {
                    focused = true
                }
                .introspect(.textEditor, on: .iOS(.v26)) { textEditor in
                    textEditor.isScrollEnabled = false
                }
                .scrollContentBackground(.hidden)
                .frame(
                    maxWidth: .infinity,
                    minHeight: bodyHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
        }
    }
}

private struct OverlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .fontWeight(.semibold)
            .imageScale(.large)
            .labelStyle(.iconOnly)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.secondary, .themedTertiaryGroupedBackground)
    }
}
