//
//  Website Icon Complex.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import CachedAsyncImage
import Foundation
import SwiftUI

struct WebsiteIconComplex: View {
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true

    @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon: Bool = true

    @State var post: APIPost

    @State private var overridenWebsiteFaviconName: String = "globe"

    @Environment(\.openURL) private var openURL

    var faviconURL: URL? {
        guard
            let baseURL = post.url?.host,
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
        if let url = post.url {
            return url.host ?? "some website"
        }
        return "some website"
    }

    var body: some View {
        VStack(spacing: 0) {
            if shouldShowWebsitePreviews, let thumbnailURL = post.thumbnailUrl {
                CachedImage(url: thumbnailURL, shouldExpand: false)
                    .frame(maxHeight: 400)
                    .applyNsfwOverlay(post.nsfw)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                if shouldShowWebsiteHost {
                    HStack {
                        if shouldShowWebsiteIcon {
                            CachedAsyncImage(url: faviconURL, urlCache: AppConstants.urlCache) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Image(systemName: "globe")
                            }
                            .frame(width: AppConstants.smallAvatarSize, height: AppConstants.smallAvatarSize)
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
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                .stroke(Color(.secondarySystemBackground), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = post.url {
                openURL(url)
            }
        }
    }
}
