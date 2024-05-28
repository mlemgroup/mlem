//
//  TilePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-27.
//

import Foundation
import MlemMiddleware
import NukeUI
import SwiftUI

struct TilePost: View {
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing

    @ScaledMetric(relativeTo: .footnote) var oneLineHeight: CGFloat = 18
    // magic number alert! ((footnote size + leading) / 2) + (vertical padding on capsules) = (18 / 2) + (2) = 11
    @ScaledMetric(relativeTo: .footnote) var cornerRadius: CGFloat = 11
    var dimension: CGFloat { UIScreen.main.bounds.width / 2 - (AppConstants.standardSpacing * 1.5) }
    var outerCornerRadius: CGFloat { cornerRadius + AppConstants.compactSpacing }
    
    var body: some View {
        content
            .frame(width: dimension, height: dimension + (oneLineHeight * 2) + (AppConstants.standardSpacing * 3) + 2)
            .background(palette.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: palette.primary.opacity(0.1), radius: 3)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            BaseImage(post: post)
                .overlay {
                    if let host = post.linkHost {
                        PostLinkHostView(host: host)
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
                }
            
            Divider()
            
            titleSection
                .padding(AppConstants.standardSpacing)
        }
    }
    
    @ViewBuilder
    var titleSection: some View {
        if case .text = post.postType {
            VStack(spacing: 2) {
                Text(post.title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: oneLineHeight * 2, maxHeight: .infinity, alignment: .top)
                
                communityAndInfo
            }
            .frame(idealHeight: 0)
        } else {
            VStack(spacing: 2) {
                Text(post.title)
                    .lineLimit(2)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: oneLineHeight * 2, alignment: .top)
                
                communityAndInfo
            }
        }
    }
    
    var communityAndInfo: some View {
        HStack {
            if let communityName = post.community_?.name {
                Text(communityName)
                    .lineLimit(1)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.secondary)
            }
            
            Spacer()
            
            info
                .lineLimit(1)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    struct BaseImage: View {
        @Environment(Palette.self) var palette: Palette
        
        let post: any Post1Providing
        
        var dimension: CGFloat { UIScreen.main.bounds.width / 2 - (AppConstants.standardSpacing * 1.5) }
        
        var body: some View {
            switch post.postType {
            case let .text(text):
                Markdown(text)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(palette.secondary)
                    .padding(AppConstants.standardSpacing)
                    .frame(maxWidth: .infinity, maxHeight: dimension, alignment: .topLeading)
                    .clipped()
            case .titleOnly:
                Image(systemName: post.placeholderImageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(palette.secondary)
                    .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .image(url):
                LazyImage(url: url) { state in
                    if let imageContainer = state.imageContainer {
                        Image(uiImage: imageContainer.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: dimension, height: dimension)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: dimension, height: dimension)
                .clipped()
            case let .link(url):
                LazyImage(url: url) { state in
                    if let imageContainer = state.imageContainer {
                        Image(uiImage: imageContainer.image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: dimension, height: dimension)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: dimension, height: dimension)
                .clipped()
            }
        }
    }
    
    // TODO: this should be fleshed out to use live values--requires some middleware work to make those conveniently available. This is just a quick-and-dirty way to mock up how it would look.
    var info: Text {
        Text(Image(systemName: Icons.upvoteSquare)) +
            Text(" 34")
//        Text(Image(systemName: Icons.upvoteSquare)) +
//            Text("34") +
//            Text("  ") +
//            Text(Image(systemName: Icons.save)) +
//            Text("  ") +
//            Text(Image(systemName: Icons.replies)) +
//            Text("12")
    }
}
