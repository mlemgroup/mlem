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
    @Environment(Palette.self) var palette
    @Environment(\.openURL) private var openURL
    
    @State var blurred: Bool
    
    let link: PostLink
    var onTapActions: (() -> Void)?
    let shouldBlur: Bool
    
    init(link: PostLink, shouldBlur: Bool, onTapActions: (() -> Void)? = nil) {
        self.link = link
        self.onTapActions = onTapActions
        self.shouldBlur = shouldBlur
        self._blurred = .init(wrappedValue: shouldBlur)
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
            .background(palette.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.mediumItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.mediumItemCornerRadius))
    }
    
    var complex: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let thumbnailUrl = link.thumbnail {
                DynamicImageView(url: thumbnailUrl.withIconSize(Constants.main.feedImageResolution), cornerRadius: 0, actionsEnabled: false)
                    .dynamicBlur(blurred: blurred)
                    .clipped()
                    .overlay {
                        NsfwOverlay(blurred: $blurred, shouldBlur: shouldBlur)
                    }
                    .animation(.easeOut(duration: 0.1), value: blurred)
                    .overlay(alignment: .bottomLeading) {
                        linkHost
                            .padding(Constants.main.halfSpacing)
                            .padding(.trailing, 3)
                            .background {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .overlay(Capsule().fill(palette.background.opacity(0.25)))
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
        }
    }
    
    var linkHost: some View {
        HStack(spacing: Constants.main.halfSpacing) {
            CircleCroppedImageView(url: link.favicon, fallback: .favicon)
                .frame(width: Constants.main.smallAvatarSize, height: Constants.main.smallAvatarSize)
            
            Text(link.host)
                .foregroundStyle(palette.secondary)
        }
        .font(.footnote)
    }
}
