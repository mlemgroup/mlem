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

struct TilePostView: View {
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing

    @ScaledMetric(relativeTo: .footnote) var minTitleHeight: CGFloat = 36 // (2 * .footnote height), including built-in spacing
    var dimension: CGFloat { (UIScreen.main.bounds.width - (AppConstants.standardSpacing * 3)) / 2 }
    var frameHeight: CGFloat {
        dimension + // picture
            minTitleHeight + // title section
            (AppConstants.standardSpacing * 3) + // vertical spacing--not actually sure why it has to be 3 instead of 2, but it does
            2 // spacing between title and community
    }
    
    var body: some View {
        content
            .frame(width: dimension, height: frameHeight)
            .background(palette.secondaryGroupedBackground)
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
        VStack(spacing: 4) {
            Text(post.title)
                .lineLimit(post.type.lineLimit)
                .foregroundStyle(post.read_ ?? false ? .secondary : .primary)
                .font(.footnote)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: minTitleHeight, alignment: .topLeading)
            
            communityAndInfo
        }
    }
    
    var titleText: some View {
        Text(post.title)
            .lineLimit(post.type.lineLimit)
            .foregroundStyle(post.read_ ?? false ? .secondary : .primary)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var communityAndInfo: some View {
        HStack(spacing: 6) {
            if let communityName = post.community_?.name {
                Text(communityName)
                    .lineLimit(1)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.secondary)
            }
            
            Spacer()
            
            score
        }
        .frame(maxWidth: .infinity)
    }
    
    struct BaseImage: View {
        @Environment(Palette.self) var palette: Palette
        
        let post: any Post1Providing
        
        var dimension: CGFloat { UIScreen.main.bounds.width / 2 - (AppConstants.standardSpacing * 1.5) }
        
        var body: some View {
            switch post.type {
            case let .text(text):
                Markdown(text)
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
    var score: some View {
        Menu {
            ForEach(post.menuActions.children, id: \.id) { action in
                MenuButton(action: action)
            }
        } label: {
            Group {
                Text(Image(systemName: Icons.upvoteSquare)) +
                    Text(" 34")
            }
            .lineLimit(1)
            .font(.caption)
            .foregroundStyle(.secondary)
            .contentShape(.rect)
        }
        .onTapGesture {}
    }
}
