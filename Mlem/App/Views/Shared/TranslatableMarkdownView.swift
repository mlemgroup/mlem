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
        if let translated = markdown.translatedMarkdown {
            VStack(alignment: .leading) {
                MarkdownWithLinkList(translated, showLinkCaptions: showLinkCaptions)
                Text("Translated")
                    .font(.footnote)
                    .foregroundStyle(.themedSecondary)
            }
        } else {
            MarkdownWithLinkList(markdown.markdown, showLinkCaptions: showLinkCaptions)
        }
    }
}
