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
    let isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            post.taggedTitle(communityContext: communityContext)
                .font(.headline)
                .imageScale(.small)
            
            switch post.type {
            case let .image(url):
                TappableImageView(url: url)
                    // Set maximum image height to 1.2 * width
                    .aspectRatio(CGSize(width: 1, height: 1.2), contentMode: .fill)
                    .frame(maxWidth: .infinity)
            case let .link(url):
                if let url {
                    mockWebsiteComplex(url: url)
                }
            default:
                EmptyView()
            }
            if let content = post.content {
                if isExpanded {
                    Markdown(content, configuration: .default)
                } else {
                    // Cut down on compute time for very long text posts by only rendering the first 4 blocks
                    MarkdownText(Array([BlockNode](content).prefix(4)), configuration: .dimmed)
                        .lineLimit(post.linkUrl == nil ? 8 : 4)
                }
            }
        }
    }
    
    var mockImage: some View {
        Image(systemName: "photo.artframe")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .foregroundStyle(palette.secondary)
    }
    
    func mockWebsiteComplex(url: URL) -> some View {
        Text(url.host ?? "no host found")
            .foregroundStyle(palette.secondary)
            .padding(AppConstants.standardSpacing)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(palette.secondary)
            }
    }
}
