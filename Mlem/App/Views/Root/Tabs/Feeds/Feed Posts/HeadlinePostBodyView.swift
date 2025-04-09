//
//  HeadlinePostBodyView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-17.
//

import MlemMiddleware
import SwiftUI

struct HeadlinePostBodyView: View {
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    
    @Setting(\.post_thumbnailLocation) var thumbnailLocation
    @Setting(\.safety_blurNsfw) var blurNsfw
    
    @ScaledMetric(relativeTo: .headline) var titleHostHeightLimit: CGFloat = 75

    let post: any Post
    var requireConsistentHeight: Bool = false
    
    var blurred: Bool {
        switch blurNsfw {
        case .always: post.nsfw
        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
        case .never: false
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: Constants.main.standardSpacing) {
            if thumbnailLocation == .left {
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .standard,
                    frame: .init(width: thumbnailSize, height: thumbnailSize)
                )
            }

            if requireConsistentHeight {
                titleAndHostView
                    .frame(height: titleHostHeightLimit, alignment: .top)
            } else {
                titleAndHostView
            }
            
            if thumbnailLocation == .right {
                Spacer()
                ThumbnailImageView(
                    post: post,
                    blurred: blurred,
                    size: .standard,
                    frame: .init(width: thumbnailSize, height: thumbnailSize)
                )
            }
        }
    }
    
    var thumbnailSize: CGFloat {
        if requireConsistentHeight, titleHostHeightLimit < Constants.main.thumbnailSize * 1.5 {
            titleHostHeightLimit
        } else {
            Constants.main.thumbnailSize
        }
    }
    
    @ViewBuilder
    var titleAndHostView: some View {
        VStack(alignment: .leading, spacing: Constants.main.halfSpacing) {
            titleView
            if let host = post.linkHost {
                PostLinkHostView(host: host)
                    .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder
    var titleView: some View {
        post.taggedTitle(communityContext: communityContext)
            .multilineTextAlignment(.leading)
            .foregroundStyle((post.read_ ?? false) ? .themedSecondary : .themedPrimary)
            .font(.headline)
            .imageScale(.small)
    }
}
