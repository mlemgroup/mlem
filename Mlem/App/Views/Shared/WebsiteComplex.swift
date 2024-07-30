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
    
    let post: any Post1Providing
    var onTapActions: (() -> Void)?
    
    var faviconUrl: URL? {
        guard
            let baseUrl = post.linkHost,
            let imageUrl = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseUrl)")
        else {
            return nil
        }
        
        return imageUrl
    }
    
    var linkLabel: String { post.embed?.title ?? post.title }
    var linkHost: String { post.linkHost ?? "unknown website" }
    
    var body: some View {
        if let url = post.linkUrl {
            content
                .contextMenu {
                    Button("Open", systemImage: Icons.browser) {
                        openURL(url)
                    }
                    Button("Copy", systemImage: Icons.copy) {
                        let pasteboard = UIPasteboard.general
                        pasteboard.url = url
                    }
                    ShareLink(item: url)
                } preview: { WebView(url: url) }
        } else {
            content
        }
    }
    
    var content: some View {
        complex
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                    .stroke(palette.secondaryBackground, lineWidth: 1)
            }
            .contentShape(.contextMenuPreview, .rect(cornerRadius: AppConstants.largeItemCornerRadius))
    }
    
    var complex: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = post.thumbnailUrl {
                ImageView(url: url, cornerRadius: 0)
                    .overlay(alignment: .bottomLeading) {
                        host
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
                host
                    .padding([.horizontal, .top], AppConstants.standardSpacing)
            }
            
            Text(linkLabel)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(AppConstants.standardSpacing)
        }
    }
    
    var host: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            if let faviconUrl {
                ImageView(url: faviconUrl, showError: false)
                    .frame(width: AppConstants.smallAvatarSize, height: AppConstants.smallAvatarSize)
                    .background {
                        Image(systemName: Icons.browser)
                            .resizable()
                            .foregroundStyle(.secondary)
                    }
            }
            
            Text(linkHost)
                .foregroundStyle(palette.secondary)
        }
        .font(.footnote)
    }
}
