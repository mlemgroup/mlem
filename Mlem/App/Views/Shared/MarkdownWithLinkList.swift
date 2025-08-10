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
    @Environment(\.scrollProxy) var scrollProxy
    
    @Setting(\.links_displayMode) var tappableLinksDisplayMode
    
    @State var linksCollapsed: Bool = true
    
    let blocks: [BlockNode]
    let markdownConfiguration: MarkdownConfigurationType
    let showLinkCaptions: Bool
    
    init(
        _ blocks: [BlockNode],
        configuration: MarkdownConfigurationType = .default,
        showLinkCaptions: Bool = true
    ) {
        self.blocks = blocks
        self.markdownConfiguration = configuration
        self.showLinkCaptions = showLinkCaptions
    }
    
    init(
        _ markdown: String,
        configuration: MarkdownConfigurationType = .default,
        showLinkCaptions: Bool = true
    ) {
        self.blocks = .init(markdown)
        self.markdownConfiguration = configuration
        self.showLinkCaptions = showLinkCaptions
    }
    
    var showSubtitle: Bool {
        tappableLinksDisplayMode == .large || tappableLinksDisplayMode == .contextual && showLinkCaptions
    }
    
    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            Markdown(blocks, configuration: .init(type: markdownConfiguration, palette: palette))
            if tappableLinksDisplayMode != .disabled {
                linksView(blocks.links.filter { !$0.insideSpoiler })
            }
        }
    }
    
    @ViewBuilder
    func linksView(_ linksData: [LinkData]) -> some View {
        if linksData.count > 3 {
            ForEach(Array(linksData[0 ..< 3].enumerated()), id: \.offset) { _, link in
                linkView(link)
            }
            
            if linksCollapsed {
                Button {
                    withAnimation {
                        linksCollapsed = false
                    }
                } label: {
                    FooterLinkView(title: String(localized: "\(linksData.count - 3) more links..."), subtitle: nil)
                }
            }
            
            if !linksCollapsed {
                ForEach(Array(linksData[3...].enumerated()), id: \.offset) { _, link in
                    linkView(link)
                }
                
                Button {
                    withAnimation {
                        linksCollapsed = true
                        scrollProxy?.scrollTo(2)
                    }
                } label: {
                    FooterLinkView(title: String(localized: "Hide links"), subtitle: nil)
                }
            }
        } else {
            ForEach(Array(linksData.enumerated()), id: \.offset) { _, link in
                linkView(link)
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
            Button("Open", icon: .general.browser) {
                openURL(data.url)
            }
            Button("Copy", icon: .general.copy) {
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
