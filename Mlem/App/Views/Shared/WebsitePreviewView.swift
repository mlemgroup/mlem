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
    
    init(link: PostLink, nsfw: Bool, onTapActions: (() -> Void)? = nil) {
        @AppStorage("safety.blurNsfw") var blurNsfw = true
        self.link = link
        self.onTapActions = onTapActions
        self.shouldBlur = blurNsfw ? nsfw : false
        self._blurred = .init(wrappedValue: blurNsfw ? nsfw : false)
    }
    
    var body: some View {
        content
            .contentShape(.rect)
            .onTapGesture {
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
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: AppConstants.largeItemCornerRadius))
    }
    
    var complex: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let thumbnailUrl = link.thumbnail {
                DynamicImageView(url: thumbnailUrl, cornerRadius: 0)
                    .blur(radius: blurred ? 50 : 0, opaque: true)
                    .clipped()
                    .overlay {
                        NsfwOverlay(blurred: $blurred, shouldBlur: shouldBlur)
                    }
                    .animation(.easeOut(duration: 0.1), value: blurred)
                    .overlay(alignment: .bottomLeading) {
                        linkHost
                            .padding(AppConstants.halfSpacing)
                            .padding(.trailing, 3)
                            .background {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .overlay(Capsule().fill(palette.background.opacity(0.25)))
                            }
                            .padding(AppConstants.halfSpacing)
                    }
            } else {
                linkHost
                    .padding([.horizontal, .top], AppConstants.standardSpacing)
            }
            
            Text(link.label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(AppConstants.standardSpacing)
        }
    }
    
    var linkHost: some View {
        HStack(spacing: AppConstants.halfSpacing) {
            CircleCroppedImageView(url: link.favicon, fallback: .favicon)
                .frame(width: AppConstants.smallAvatarSize, height: AppConstants.smallAvatarSize)
            
            Text(link.host)
                .foregroundStyle(palette.secondary)
        }
        .font(.footnote)
    }
}