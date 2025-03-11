//
//  WebsitePreviewView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-16.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct WebsitePreviewView: View {
    @Environment(\.openURL) private var openURL
    
    @Setting(\.showFavicons) var showFavicons

    let shouldBlur: Bool
    
    let link: PostLink
    var onTapActions: (() -> Void)?
    
    init(link: PostLink, shouldBlur: Bool, onTapActions: (() -> Void)? = nil) {
        self.link = link
        self.onTapActions = onTapActions
        self.shouldBlur = shouldBlur
    }
    
    var body: some View {
        content
            .contentShape(.rect)
            .onTapGesture {
                if let onTapActions {
                    onTapActions()
                }
                openURL(link.content)
            }
            .contextMenu {
                Button("Open", systemImage: Icons.browser) {
                    openURL(link.content)
                }
                Button("Copy", systemImage: Icons.copy) {
                    let pasteboard = UIPasteboard.general
                    pasteboard.url = link.content
                }
                ShareLink(item: link.content)
            } preview: { WebView(url: link.content) }
    }
    
    var content: some View {
        complex
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.themedTertiaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.mediumItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
            .paletteBorder(cornerRadius: Constants.main.mediumItemCornerRadius)
    }
    
    var complex: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let thumbnailUrl = link.thumbnail {
                MediaView(
                    url: thumbnailUrl,
                    controlState: .constant(.init(
                        blurred: shouldBlur,
                        animating: false,
                        overlays: shouldBlur ? [.controls, .nsfw, .error] : [.controls, .error]
                    )),
                    aspectRatioBounds: .bounded(vertical: .init(width: 1, height: 1), horizontal: nil),
                    contentMode: .fill
                )
                .overlay(alignment: .bottomLeading) {
                    linkHost
                        .padding(Constants.main.halfSpacing)
                        .padding(showFavicons ? .trailing : .horizontal, 3)
                        .background {
                            Capsule()
                                .fill(.regularMaterial)
                                .overlay(Capsule().fill(.themedBackground.opacity(0.25)))
                        }
                        .padding(Constants.main.halfSpacing)
                }
            } else {
                linkHost
                    .padding([.horizontal, .top], Constants.main.standardSpacing)
            }
            
            Text(link.label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(Constants.main.standardSpacing)
                .foregroundStyle(.themedPrimary)
        }
    }
    
    var linkHost: some View {
        HStack(spacing: Constants.main.halfSpacing) {
            if showFavicons {
                CircleCroppedImageView(url: link.favicon, frame: Constants.main.smallAvatarSize, fallback: .favicon)
            }
            
            Text(link.host)
                .foregroundStyle(.themedSecondary)
        }
        .font(.footnote)
    }
}
