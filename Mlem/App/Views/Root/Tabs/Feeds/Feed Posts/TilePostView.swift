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
    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    
    @Environment(AppState.self) private var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(\.parentFrameWidth) var parentFrameWidth: CGFloat
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    let post: Post

    // Note that these dimensions above sum to precisely the height of TileCommentView, though due to the grouping of title and community here, we get a bonus 10px for the content
    // Total height in simplest form is:
    // width + minTitleHeight + communityHeight + 17
    @ScaledMetric(relativeTo: .footnote) var minTitleHeight: CGFloat = 36 // (2 * .footnote height), including built-in spacing
    @ScaledMetric(relativeTo: .caption) var communityHeight: CGFloat = 16 // .caption height, including built-in spacing
    
    let contentHeightModifier: CGFloat = 10
    // width cannot go below contentHeightModifier so contentWidth is never negative
    var width: CGFloat { max(contentHeightModifier, (parentFrameWidth - (Constants.main.standardSpacing * 3)) / 2) }
    var contentHeight: CGFloat { width - contentHeightModifier }
    var frameHeight: CGFloat { width + minTitleHeight + communityHeight + 17 }
    // Padding math
    // Need to satisfy: padding + contentHeightModifier = 17
    //
    // Title : community spacing = 7
    // Title + community external padding = (2 * Constants.main.standardSpacing) = 20
    //
    // Total padding = 27
    // 27 + contentHeightModifier = 17
    // contentHeightModifier = 10

    var body: some View {
        content
            .frame(width: width, height: frameHeight)
            .background(.themedSecondaryGroupedBackground)
            .clipShape(.rect(cornerRadius: Constants.main.largeItemCornerRadius))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.largeItemCornerRadius))
            .environment(\.postContext, post)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            BaseImage(post: post, width: width, height: contentHeight)
            
            Divider()
            
            VStack(spacing: 7) {
                titleSection
                    .typesettingLanguage(.init(languageCode: .english))
                
                nameAndInfo
            }
            .padding(Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    var titleSection: some View {
        post.taggedTitle(communityContext: communityContext)
            .symbolVariant(.fill)
            .lineLimit(post.type.lineLimit)
            .foregroundStyle(post.read.value ?? false ? .themedSecondary : .themedPrimary)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, minHeight: minTitleHeight, alignment: .topLeading)
    }

    var nameAndInfo: some View {
        HStack(spacing: 6) {
            Group {
                if communityContext != nil {
                    ExpectedView(post.creator) { creator in
                        Text(creator.name)
                    } placeholder: {
                        Text(verbatim: .personPlaceholder).redacted(reason: .placeholder)
                    }
                } else {
                    ExpectedView(post.community) { community in
                        Text(community.name)
                    } placeholder: {
                        Text(verbatim: .communityPlaceholder).redacted(reason: .placeholder)
                    }
                }
            }
            .lineLimit(1)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.themedSecondary)
            
            Spacer()
            
            if differentiateWithoutColor, readPostIndicator == .checkmark {
                ReadCheck(read: post.read, tiled: true)
            }
            
            score
        }
        .frame(maxWidth: .infinity)
    }
    
    var score: some View {
        Menu {
            ForEach(post.allMenuActions(
                appState: appState,
                showAllActions: false,
                navigation: navigation,
                commentTreeTracker: commentTreeTracker
            ), id: \.id) { action in
                MenuButton(action: action)
            }
        } label: {
            TileScoreView(saved: post.saved.value ?? false, votes: post.votes.value ?? .init(upvotes: 0, downvotes: 0, myVote: .none))
        }
        .onTapGesture {}
        .popupAnchor()
    }
    
    // MARK: - BaseImage
    
    struct BaseImage: View {
        @Environment(\.palette) var palette
        @Environment(\.communityContext) var communityContext
        
        @Setting(\.safety_blurNsfw) var blurNsfw
        
        let post: Post
        
        let width: CGFloat
        let height: CGFloat
        
        var blurred: Bool {
            switch blurNsfw {
            case .always: post.nsfw
            case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
            case .never: false
            }
        }
        
        var body: some View {
            content
                .overlay {
                    if post.nsfw {
                        Image(icon: .lemmy.nsfwTag)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.themedBackground, .themedWarning)
                            .imageScale(.small)
                            .padding(.top, Constants.main.standardSpacing)
                            .padding(.trailing, Constants.main.halfSpacing)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                }
        }
        
        @ViewBuilder
        var content: some View {
            switch post.type {
            case let .text(text):
                MarkdownText(text, configuration: .caption(palette: palette))
                    .foregroundStyle(.themedSecondary)
                    .padding(Constants.main.standardSpacing)
                    .frame(maxWidth: .infinity, maxHeight: height, alignment: .topLeading)
                    .clipped()
            case .titleOnly:
                Image(icon: post.imageFallback.icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.themedSecondary)
                    .frame(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .media, .embedded:
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .tile,
                    frame: .init(width: width, height: height)
                )
                .clipped()
            case let .link(link):
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .tile,
                    frame: .init(width: width, height: height)
                )
                .aspectRatio(contentMode: .fill)
                .clipped()
                .overlay { linkHostOverlay(link) }
            }
        }
        
        func linkHostOverlay(_ link: PostLink) -> some View {
            PostLinkHostView(host: link.host)
                .font(.caption)
                .padding(2)
                .padding(.horizontal, 4)
                .background {
                    Capsule()
                        .fill(.regularMaterial)
                        .overlay(Capsule().fill(.themedBackground.opacity(0.25)))
                }
                .padding(Constants.main.compactSpacing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }
}
