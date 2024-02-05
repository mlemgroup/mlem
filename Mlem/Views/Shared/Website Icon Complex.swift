//
//  Website Icon Complex.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI

struct WebsiteIconComplex: View {
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true

    @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon: Bool = true

    let post: APIPost
    var onTapActions: (() -> Void)?
    
    init(
        post: APIPost,
        onTapActions: (() -> Void)? = nil
    ) {
        self.post = post
        self.onTapActions = onTapActions
    }

    @State private var overridenWebsiteFaviconName: String = "globe"

    @Environment(\.openURL) private var openURL

    var faviconURL: URL? {
        guard
            let baseURL = post.linkUrl?.host,
            let imageURL = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseURL)")
        else {
            return nil
        }

        return imageURL
    }
    
    var linkLabel: String {
        if let embedTitle = post.embedTitle {
            return embedTitle
        } else {
            return post.name
        }
    }
    
    var linkHost: String {
        if let url = post.linkUrl {
            return url.host ?? "some website"
        }
        return "some website"
    }
    
    // REMOVEME: needed for TF hack
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var screenWidth: CGFloat = UIScreen.main.bounds.width - (AppConstants.postAndCommentSpacing * 2)
    var imageWidth: CGFloat { horizontalSizeClass == .regular ? screenWidth * 0.8 : screenWidth }
    var imageHeight: CGFloat { horizontalSizeClass == .regular ? 400 : screenWidth * 0.66 }

    var body: some View {
        LazyVStack(spacing: 0) {
            if shouldShowWebsitePreviews, let thumbnailURL = post.thumbnailImageUrl {
                CachedImage(
                    url: thumbnailURL,
                    shouldExpand: false,
                    // CHANGEME: hack for TF release
                    fixedSize: CGSize(width: imageWidth, height: imageHeight)
                )
                // .frame(maxHeight: 400)
                .frame(width: imageWidth, height: imageHeight)
                .applyNsfwOverlay(post.nsfw)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                if shouldShowWebsiteHost {
                    HStack {
                        if shouldShowWebsiteIcon {
                            CachedImage(
                                url: faviconURL,
                                shouldExpand: false,
                                fixedSize: CGSize(width: AppConstants.smallAvatarSize, height: AppConstants.smallAvatarSize),
                                imageNotFound: { AnyView(Image(systemName: Icons.websiteIcon)) }
                            )
                        }
                        
                        Text(linkHost)
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text(linkLabel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppConstants.postAndCommentSpacing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isLink)
        .accessibilityLabel("\(linkLabel) from \(linkHost)")
        .cornerRadius(AppConstants.largeItemCornerRadius)
        .background(Color.systemBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                .stroke(Color(.secondarySystemBackground), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = post.linkUrl {
                openURL(url)
                if let onTapActions {
                    onTapActions()
                }
            }
        }
        .ifLet(post.linkUrl) { url, content in
            content
                .contextMenu {
                    if let url = post.linkUrl {
                        Button("Open", systemImage: Icons.browser) {
                            openURL(url)
                            if let onTapActions {
                                onTapActions()
                            }
                        }
                        Button("Copy", systemImage: Icons.copy) {
                            let pasteboard = UIPasteboard.general
                            pasteboard.url = url
                        }
                        ShareLink(item: url)
                    }
                } preview: {
                    if let url = post.linkUrl { WebView(url: url) }
                }
        }
    }
}
