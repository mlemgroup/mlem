//
//  MarkdownWithLinkList.swift
//  Mlem
//
//  Created by Sjmarf on 12/10/2024.
//

import LemmyMarkdownUI
import SwiftUI

struct MarkdownWithLinkList: View {
    @Environment(Palette.self) var palette
    @Environment(\.openURL) var openURL
    
    @Setting(\.tappableLinksDisplayMode) var tappableLinksDisplayMode
    
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
            if tappableLinksDisplayMode != .disabled {
                ForEach(
                    Array(blocks.links.filter { !$0.insideSpoiler }.enumerated()),
                    id: \.offset
                ) { _, link in
                    linkView(link)
                }
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

            if tappableLinksDisplayMode == .large || tappableLinksDisplayMode == .contextual && showLinkCaptions {
                Text(data.url.absoluteURL.description)
                    .font(.footnote)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(palette.secondary)
        .padding(Constants.main.standardSpacing)
        .background(palette.tertiaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
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

enum TappableLinksDisplayMode: String, Codable, CaseIterable {
    case disabled, large, compact, contextual
}
