//
//  TranslatableMarkdownView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-16.
//

import SwiftUI
import MlemMiddleware

struct TranslatableMarkdownView: View {
    let markdown: TranslatableMarkdown
    var configuration: MarkdownConfigurationType = .default
    var showLinkCaptions: Bool = true

    var body: some View {
        switch markdown.translated {
        case let .translated(translated):
            VStack(alignment: .leading) {
                MarkdownWithLinkList(translated, showLinkCaptions: showLinkCaptions)
                Text("Translated")
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
            }
        case .translating:
            VStack(alignment: .leading) {
                MarkdownWithLinkList(markdown.markdown, showLinkCaptions: showLinkCaptions)
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Translating...")
                }
                .font(.footnote)
                .foregroundStyle(.themedSecondary)
            }
        case .untranslated:
            MarkdownWithLinkList(markdown.markdown, showLinkCaptions: showLinkCaptions)
        }
    }
}
