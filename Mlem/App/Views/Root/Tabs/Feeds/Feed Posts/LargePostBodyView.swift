//
//  LargePostBodyView.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct LargePostBodyView: View {
    @Environment(Palette.self) var palette
    @Environment(\.communityContext) private var communityContext:
        (any Community1Providing)?
    @Environment(\.openURL) private var openURL

    let post: any Post1Providing
    let isPostPage: Bool
    let shouldBlur: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            post.taggedTitle(communityContext: communityContext)
                .foregroundStyle(
                    (post.read_ ?? false && !isPostPage)
                        ? palette.secondary : palette.primary
                )
                .font(.headline)
                .imageScale(.small)

            switch post.type {
            case let .media(url):
                mediaView(url)
            case let .embedded(url, originalLink):
                VStack(spacing: Constants.main.standardSpacing) {
                    mediaView(url)
                    
                    
                    if isPostPage {
                        Button("View on \(originalLink.host() ?? "original host")") {
                            openURL(originalLink)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            case let .link(link):
                WebsitePreviewView(link: link, shouldBlur: shouldBlur) {
                    post.markRead()
                }
            default:
                EmptyView()
            }
            if let content = post.content {
                if isPostPage {
                    MarkdownWithLinkList(content)
                } else {
                    // Cut down on compute time for very long text posts by only rendering the first 4 blocks
                    MarkdownText(
                        Array([BlockNode](content).prefix(4)),
                        configuration: .dimmed
                    )
                    .lineLimit(post.linkUrl == nil ? 8 : 4)
                }
            }
        }
        .environment(\.postContext, post)
    }
    
    @ViewBuilder
    func mediaView(_ url: URL) -> some View {
        MediaView(
            url: url,
            verticalAspectRatioBounds: .init(width: 4, height: 5),
            cornerRadius: Constants.main.mediumItemCornerRadius,
            enableContextMenu: true,
            enableImageViewer: true,
            enableNsfwBlur: shouldBlur
        ) {
            post.markRead()
        }
    }
}
