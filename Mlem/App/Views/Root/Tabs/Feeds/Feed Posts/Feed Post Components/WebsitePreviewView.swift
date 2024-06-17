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
            let baseURL = post.linkUrl?.host,
            let imageURL = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseURL)")
        else {
            return nil
        }
        
        return imageURL
    }
    
    var linkLabel: String { post.embed?.title ?? post.title }
    var linkHost: String { post.linkHost ?? "unknown website" }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppConstants.standardSpacing)
            .overlay {
                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                    .stroke(palette.secondaryBackground, lineWidth: 1)
            }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            if let url = post.thumbnailUrl {
                ImageView(url: url)
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
            }
            
            Text(linkLabel)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
    
    var host: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            if let faviconUrl {
                ImageView(url: faviconUrl)
                    .frame(width: AppConstants.smallAvatarSize, height: AppConstants.smallAvatarSize)
            }
            
            Text(linkHost)
                .foregroundStyle(palette.secondary)
        }
        .font(.footnote)
    }
}
