//
//  TilePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-27.
//

import Foundation
import LemmyMarkdownUI
import MlemMiddleware
import NukeUI
import SwiftUI

struct TilePostView: View {
    @Environment(Palette.self) var palette: Palette
    @Environment(\.parentFrameWidth) var parentFrameWidth: CGFloat
    
    let post: any Post1Providing

    // Note that these dimensions above sum to precisely the height of TileCommentView, though due to the grouping of title and community here, we get a bonus 10px for the content
    // Total height in simplest form is:
    // width + minTitleHeight + communityHeight + 17
    @ScaledMetric(relativeTo: .footnote) var minTitleHeight: CGFloat = 36 // (2 * .footnote height), including built-in spacing
    @ScaledMetric(relativeTo: .caption) var communityHeight: CGFloat = 16 // .caption height, including built-in spacing
    
    let contentHeightModifier: CGFloat = 10
    // width cannot go below contentHeightModifier so contentWidth is never negative
    var width: CGFloat { max(contentHeightModifier, (parentFrameWidth - (AppConstants.standardSpacing * 3)) / 2) }
    var contentHeight: CGFloat { width - contentHeightModifier }
    var frameHeight: CGFloat { width + minTitleHeight + communityHeight + 17 }
    // Padding math
    // Need to satisfy: padding + contentHeightModifier = 17
    //
    // Title : community spacing = 7
    // Title + community external padding = (2 * AppConstants.standardSpacing) = 20
    //
    // Total padding = 27
    // 27 + contentHeightModifier = 17
    // contentHeightModifier = 10

    var body: some View {
        content
            .frame(width: width, height: frameHeight)
            .background(palette.secondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: AppConstants.tilePostCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: AppConstants.tilePostCornerRadius))
            .environment(\.postContext, post)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            BaseImage(post: post, width: width, height: contentHeight)
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
            
            VStack(spacing: 7) {
                titleSection
                    .typesettingLanguage(.init(languageCode: .english))
                
                communityAndInfo
            }
            .padding(AppConstants.standardSpacing)
        }
    }
    
    @ViewBuilder
    var titleSection: some View {
        Text(post.title)
            .lineLimit(post.type.lineLimit)
            .foregroundStyle(post.read_ ?? false ? palette.secondary : palette.primary)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, minHeight: minTitleHeight, alignment: .topLeading)
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
        
        @AppStorage("safety.blurNsfw") var blurNsfw = true
        
        let post: any Post1Providing
        
        let width: CGFloat
        let height: CGFloat
        
        var body: some View {
            switch post.type {
            case let .text(text):
                MarkdownText(text, configuration: .caption)
                    .foregroundStyle(palette.secondary)
                    .padding(AppConstants.standardSpacing)
                    .frame(maxWidth: .infinity, maxHeight: height, alignment: .topLeading)
                    .clipped()
            case .titleOnly:
                Image(systemName: post.placeholderImageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(palette.secondary)
                    .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .image(url):
                TappableImageView(url: url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .background(palette.secondaryBackground)
                    .blur(radius: (post.nsfw && blurNsfw) ? 20 : 0, opaque: true)
                    .clipped()
            case let .link(url):
                ImageView(url: url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .background(palette.secondaryBackground)
                    .blur(radius: (post.nsfw && blurNsfw) ? 20 : 0, opaque: true)
                    .clipped()
            }
        }
    }
    
    var score: some View {
        Menu {
            ForEach(post.menuActions(), id: \.id) { action in
                MenuButton(action: action)
            }
        } label: {
            Group {
                Text(Image(systemName: post.votes_?.iconName ?? Icons.upvoteSquare)) +
                    Text(verbatim: " \(post.votes_?.total.abbreviated ?? "0")")
            }
            .lineLimit(1)
            .font(.caption)
            .foregroundStyle(post.votes_?.iconColor ?? palette.secondary)
            .contentShape(.rect)
        }
        .onTapGesture {}
    }
}
