//
//  MarkdownWithLinkList.swift
//  Mlem
//
//  Created by Sjmarf on 12/10/2024.
//

import LemmyMarkdownUI
import SwiftUI

struct MarkdownWithLinkList: View {
    @Environment(\.palette) var palette
    @Environment(\.openURL) var openURL
    
    @Setting(\.links_displayMode) var tappableLinksDisplayMode
    
    let blocks: [BlockNode]
    let shouldBlur: Bool
    let showLinkCaptions: Bool
    
    init(_ blocks: [BlockNode], shouldBlur: Bool = false, showLinkCaptions: Bool = true) {
        self.blocks = blocks
        self.shouldBlur = shouldBlur
        self.showLinkCaptions = showLinkCaptions
    }
    
    init(_ markdown: String, shouldBlur: Bool = false, showLinkCaptions: Bool = true) {
        self.blocks = .init(markdown)
        self.shouldBlur = shouldBlur
        self.showLinkCaptions = showLinkCaptions
    }
    
    var showSubtitle: Bool {
        tappableLinksDisplayMode == .large || tappableLinksDisplayMode == .contextual && showLinkCaptions
    }
    
    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            Markdown(blocks, configuration: shouldBlur ? .defaultBlurred(palette: palette) : .default(palette: palette))
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
        FooterLinkView(
            title: data.stringTitle,
            subtitle: showSubtitle ? data.url.absoluteURL.description : nil
        )
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
