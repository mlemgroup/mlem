//
//  LinkEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-11-04.
//  

import MlemMiddleware
import SwiftUI
import Theming

struct LinkEditorView: View {
    @Environment(\.palette) var palette
    let api: ApiClient
    let close: (PostLink) -> Void
    
    let originalUrl: URL
    
    init(url: URL, api: ApiClient, close: @escaping (PostLink) -> Void) {
        self.api = api
        self.close = close
        self.originalUrl = url
    }
    
    @State var urlString: String = ""
    @State var textView: UITextView?
    @FocusState var focused: Bool

    var attributedStringBinding: Binding<AttributedString> {
        .init {
            var string = AttributedString(urlString)
            string.foregroundColor = ThemedColor.themedSecondary.resolve(with: palette)
            if let url = URL(string: urlString), let host = url.host() {
                if let range = string.range(of: host) {
                    string[range].foregroundColor = ThemedColor.themedPrimary.resolve(with: palette)
                }
            }
            return string
        } set: { 
            urlString = String($0.characters)
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Button("Go back", icon: .general.backward) {
                    if let url = URL(string: self.urlString) {
                        focused = false
                        Task {
                            do {
                                let link = try await api.getPostLinkOrUseOpenGraph(url: url)
                                close(link)
                            } catch {
                                handleError(error)
                            }
                        }
                    }
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
        Group {
            if #available(iOS 26.0, *) {
                TextEditor(text: attributedStringBinding)
            } else {
                TextEditor(text: $urlString)
            }
        }
        .focused($focused)
        .onAppear {
            focused = true
        }
        .fixedSize(horizontal: false, vertical: true)
        .layoutPriority(6)
        .frame(maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .introspect(.textEditor, on: .iOS(.v26)) {
            if textView == nil {
                textView = $0
                // The text has to be set here; otherwise the textview has a height of 0 for some reason
                textView?.text = originalUrl.absoluteString
            }
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
