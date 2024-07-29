//
//  WebsiteComplex.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-29.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct WebsiteComplex: View {
    @Environment(Palette.self) var palette
    
    let post: any Post1Providing
    
    @ScaledMetric(relativeTo: .caption) var capsuleHeight: CGFloat = 16
    
    var faviconUrl: URL? {
        guard
            let baseURL = post.linkUrl?.host,
            let imageURL = URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseURL)")
        else {
            return nil
        }
        
        return imageURL
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let url = post.thumbnailUrl {
                ImageView(url: url)
                    .overlay {
                        linkHost
                            .font(.caption)
                            .padding(2)
                            .padding(.horizontal, 4)
                            .background {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .overlay(Capsule().fill(palette.background.opacity(0.25)))
                            }
                            .padding(AppConstants.compactSpacing)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
            } else {
                PostLinkHostView(host: post.linkHost ?? "unknown host")
            }
            
            Divider()
            
            Text(post.embed?.title ?? post.title)
        }
//        Text(post.linkHost ?? "no host found")
//            .foregroundStyle(palette.secondary)
//            .padding(AppConstants.standardSpacing)
//            .frame(maxWidth: .infinity)
//            .overlay {
//                RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
//                    .stroke(lineWidth: 1)
//                    .foregroundStyle(palette.secondary)
//            }
    }
    
    @ViewBuilder
    var linkHost: some View {
        HStack(spacing: AppConstants.halfSpacing) {
            Group {
                if let faviconUrl {
                    ImageView(url: faviconUrl)
                } else {
                    Image(systemName: Icons.websiteIcon)
                }
            }
            .frame(width: capsuleHeight, height: capsuleHeight)
            
            Text(post.linkHost ?? "unknown host")
                .font(.caption)
                .foregroundStyle(palette.secondary)
        }
    }
}
