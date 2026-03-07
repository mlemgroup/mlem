//
//  CompactPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct CompactPostView: View {
    @Setting(\.post_thumbnailLocation) var thumbnailLocation
    @Setting(\.safety_blurNsfw) var blurNsfw
    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    @Setting(\.post_showDownvotesCompact) var showDownvotesCompact
    
    @Environment(\.communityContext) var communityContext: Community?
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    @ScaledMetric(relativeTo: .caption) var titleHostHeightLimit: CGFloat = 40
    
    let post: Post
    var requireConsistentHeight: Bool = false
    
    var readouts: [PostBarConfiguration.ReadoutType?] {
        let saved: PostBarConfiguration.ReadoutType? = post.saved.value ?? false ? .saved : nil
        if showDownvotesCompact {
            return [.created, .upvote, .downvote, .comment, saved]
        } else {
            return [.created, .score, .comment, saved]
        }
    }
    
    var blurred: Bool {
        switch blurNsfw {
        case .always: post.nsfw
        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
        case .never: false
        }
    }
    
    var body: some View {
        content
            .padding(Constants.main.standardSpacing)
            .background(.themedSecondaryGroupedBackground)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        HStack(alignment: .top, spacing: Constants.main.standardSpacing) {
            if thumbnailLocation == .left {
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .standard,
                    frame: .init(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                )
            }
            
            VStack(alignment: .leading, spacing: Constants.main.compactSpacing) {
                HStack(spacing: 4) {
                    if communityContext != nil {
                        ExpectedView(post.creator) { creator in
                            FullyQualifiedLinkView(creator, labelStyle: .small, showAvatar: false)
                        } placeholder: {
                            Text(verbatim: .personPlaceholder).redacted(reason: .placeholder)
                        }
                    } else {
                        ExpectedView(post.community) { community in
                            FullyQualifiedLinkView(community, labelStyle: .small, showAvatar: false)
                        } placeholder: {
                            Text(verbatim: .communityPlaceholder).redacted(reason: .placeholder)
                        }
                        
                    }
                    Spacer()
                    
                    if differentiateWithoutColor, readPostIndicator == .checkmark {
                        ReadCheck(read: post.read)
                    }
                    
                    if post.nsfw {
                        Image(icon: .lemmy.nsfwTag)
                            .foregroundStyle(.themedWarning)
                            .imageScale(.small)
                    }
                    
                    // Allow the tap area to extend outside of the parent HStack a little
                    PostEllipsisMenus(post: post, size: 20)
                        .padding(.vertical, -2)
                }
                .padding(.bottom, -2)
                if requireConsistentHeight {
                    titleAndHostView
                        .frame(height: titleHostHeightLimit, alignment: .top)
                } else {
                    titleAndHostView
                }
                InfoStackView(post: post, readouts: readouts, coloredReadouts: .init(PostBarConfiguration.ReadoutType.allCases))
            }
            .frame(maxWidth: .infinity)
            
            if thumbnailLocation == .right {
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .standard,
                    frame: .init(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    var titleAndHostView: some View {
        VStack(alignment: .leading, spacing: Constants.main.compactSpacing) {
            titleView
            if let host = post.linkHost {
                PostLinkHostView(host: host)
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    var titleView: some View {
        post.taggedTitle(communityContext: communityContext)
            .symbolVariant(.fill)
            .multilineTextAlignment(.leading)
            .imageScale(.small)
            .foregroundStyle(post.read.value ?? false ? .themedSecondary : .themedPrimary)
            .font(.subheadline)
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
//        DevCompactPostView(post: Post2.mock(.generic))
//    }
// #endif
