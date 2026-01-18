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
    @Environment(\.palette) var palette
    @Environment(\.communityContext) private var communityContext: (any Community1Providing)?

    let post: Post
    let isPostPage: Bool
    let shouldBlur: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            post.taggedTitle(communityContext: communityContext)
                .foregroundStyle(
                    (post.read.value ?? false && !isPostPage)
                        ? .themedSecondary : .themedPrimary
                )
                .font(.headline)
                .symbolVariant(.fill)
                .imageScale(.small)

            switch post.type {
            case let .media(url):
                mediaView(url)
            case let .embedded(url, originalLink):
                VStack(spacing: Constants.main.standardSpacing) {
                    mediaView(url)
                    
                    if isPostPage {
                        OpenInLoopsButton(url: originalLink)
                    }
                }
            case let .link(link):
                WebsitePreviewView(link: link, shouldBlur: shouldBlur) {
                    post.updateRead(true)
                }
            default:
                EmptyView()
            }
            if let content = post.content {
                if isPostPage {
                    MarkdownWithLinkList(content, configuration: shouldBlur ? .defaultBlurred : .default)
                } else {
                    // Cut down on compute time for very long text posts by only rendering the first 4 blocks
                    MarkdownText(
                        Array([BlockNode](content).prefix(4)),
                        configuration: .dimmed(palette: palette)
                    )
                    .lineLimit(post.linkUrl == nil ? 8 : 4)
                }
            }
        }
        .environment(\.postContext, post)
    }
    
    @ViewBuilder
    func mediaView(_ url: URL) -> some View {
        MediaView.largeImage(url: url, shouldBlur: shouldBlur) {
            post.updateRead(true)
        }
        .frame(maxWidth: .infinity)
    }
    
    // @Environment(\.openURL) combined with the conditionally displayed url in .embedded causes significant lag
    // due to openURL-based redraws, so we pull this into its own view to isolate openURL
    private struct OpenInLoopsButton: View {
        @Environment(\.openURL) private var openURL
        
        let url: URL
        
        var body: some View {
            Button(String(localized: loopsButtonText(originalLink: url))) {
                openURL(url)
            }
            .buttonStyle(.bordered)
        }
        
        func loopsButtonText(originalLink: URL) -> LocalizedStringResource {
            if let host = originalLink.host() {
                return "View on \(host)"
            } else {
                return "View on original host"
            }
        }
    }
}
