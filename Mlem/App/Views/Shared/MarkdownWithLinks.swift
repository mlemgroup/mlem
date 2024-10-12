//
//  MarkdownWithLinks.swift
//  Mlem
//
//  Created by Sjmarf on 12/10/2024.
//

import LemmyMarkdownUI
import SwiftUI

struct MarkdownWithLinks: View {
    @Environment(Palette.self) var palette
    @Environment(\.openURL) var openURL
    
    let blocks: [BlockNode]
    let showLinkCaptions: Bool
    
    init(_ blocks: [BlockNode], showLinkCaptions: Bool = true) {
        self.blocks = blocks
        self.showLinkCaptions = showLinkCaptions
    }
    
    init(_ markdown: String, showLinkCaptions: Bool = true) {
        self.blocks = .init(markdown)
        self.showLinkCaptions = showLinkCaptions
    }
    
    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            Markdown(blocks, configuration: .default)
            ForEach(Array(blocks.links.enumerated()), id: \.offset) { _, link in
                linkView(link)
            }
        }
    }
    
    @ViewBuilder
    func linkView(_ data: LinkData) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(data.stringTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.subheadline)
                .fontWeight(.semibold)

            if showLinkCaptions {
                Text(data.url.absoluteURL.description)
                    .font(.footnote)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(palette.secondary)
        .padding(Constants.main.standardSpacing)
        // TODO: before merge: Add OLED palette border
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu {
            Button("Open", systemImage: Icons.browser) {
                openURL(data.url)
            }
            Button("Copy", systemImage: Icons.copy) {
                let pasteboard = UIPasteboard.general
                pasteboard.url = data.url
            }
            ShareLink(item: data.url)
        } preview: {
            WebView(url: data.url)
        }
        .onTapGesture {
            openURL(data.url)
        }
    }
}

private extension LinkData {
    var stringTitle: String {
        let literal = title.stringLiteral
        if literal == url.absoluteString {
            return url.host() ?? literal
        }
        return literal
    }
}
