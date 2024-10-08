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
    @Environment(\.communityContext) private var communityContext: (any Community1Providing)?
    
    let post: any Post1Providing
    let isPostPage: Bool
    let shouldBlur: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            post.taggedTitle(communityContext: communityContext)
                .foregroundStyle((post.read_ ?? false && !isPostPage) ? palette.secondary : palette.primary)
                .font(.headline)
                .imageScale(.small)
            
            switch post.type {
            case let .image(url):
                LargeImageView(
                    url: url,
                    shouldBlur: shouldBlur
                ) {
                    post.markRead()
                }
                // Set maximum image height to 1.2 * width
                .aspectRatio(CGSize(width: 1, height: 1.2), contentMode: .fill)
                .frame(maxWidth: .infinity)
            case let .link(link):
                WebsitePreviewView(link: link, shouldBlur: shouldBlur) {
                    post.markRead()
                }
            default:
                EmptyView()
            }
            if let content = post.content {
                if isPostPage {
                    Markdown(content, configuration: .default)
                } else {
                    // Cut down on compute time for very long text posts by only rendering the first 4 blocks
                    MarkdownText(Array([BlockNode](content).prefix(4)), configuration: .dimmed)
                        .lineLimit(post.linkUrl == nil ? 8 : 4)
                }
            }
        }
        .environment(\.postContext, post)
    }
}
