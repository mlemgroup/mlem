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
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.blurNsfw) var blurNsfw
    @Setting(\.readPostIndicator) var readPostIndicator
    @Setting(\.showDownvotesCompact) var showDownvotesCompact
    
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(Palette.self) var palette: Palette
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    @ScaledMetric(relativeTo: .caption) var titleHostHeightLimit: CGFloat = 40
    
    let post: any Post1Providing
    var requireConsistentHeight: Bool = false

    var readouts: [PostBarConfiguration.ReadoutType?] {
        let saved: PostBarConfiguration.ReadoutType? = post.saved_ ?? false ? .saved : nil
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
            .background(palette.secondaryGroupedBackground)
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
                        FullyQualifiedLinkView(post.creator_, labelStyle: .small, showAvatar: false)
                    } else {
                        FullyQualifiedLinkView(post.community_, labelStyle: .small, showAvatar: false)
                    }
                    Spacer()

                    if differentiateWithoutColor, readPostIndicator == .checkmark, post.read_ ?? false {
                        ReadCheck()
                    }
                    
                    if post.nsfw {
                        Image(Icons.nsfwTag)
                            .foregroundStyle(palette.warning)
                            .imageScale(.small)
                    }

                    // Allow the tap area to extend outside of the parent HStack a little
                    PostEllipsisMenus(post: post, size: 22)
                        .padding(.vertical, -4)
                }
                .padding(.bottom, -2)
                if requireConsistentHeight {
                    titleAndHostView
                        .frame(height: titleHostHeightLimit, alignment: .top)
                } else {
                    titleAndHostView
                }
                InfoStackView(post: post, readouts: readouts, showColor: true)
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
            .multilineTextAlignment(.leading)
            .imageScale(.small)
            .foregroundStyle(post.read_ ?? false ? palette.secondary : palette.primary)
            .font(.subheadline)
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
        CompactPostView(post: Post2.mock(.generic))
    }
#endif
