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
    
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    
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
                        FullyQualifiedLinkView(entity: post.creator_, labelStyle: .small, showAvatar: false)
                    } else {
                        FullyQualifiedLinkView(entity: post.community_, labelStyle: .small, showAvatar: false)
                    }
                    Spacer()
                    
                    if post.nsfw {
                        Image(Icons.nsfwTag)
                            .foregroundStyle(palette.warning)
                            .imageScale(.small)
                    }

                    PostEllipsisMenus(post: post, size: 18)
                }
                .padding(.bottom, -2)
  
                post.taggedTitle(communityContext: communityContext)
                    .imageScale(.small)
                    .foregroundStyle(post.read_ ?? false ? palette.secondary : palette.primary)
                    .font(.subheadline)
                
                if let host = post.linkHost {
                    PostLinkHostView(host: host)
                        .font(.caption)
                }
                
                InfoStackView(post: post, readouts: [.created, .score, .comment, post.saved_ ?? false ? .saved : nil], showColor: true)
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
}
