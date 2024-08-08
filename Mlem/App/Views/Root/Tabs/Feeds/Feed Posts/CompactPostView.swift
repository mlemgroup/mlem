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
    
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .padding(Constants.main.standardSpacing)
            .background(palette.background)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        HStack(alignment: .top, spacing: Constants.main.standardSpacing) {
            if thumbnailLocation == .left {
                ThumbnailImageView(post: post, blurred: post.nsfw, size: .standard)
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

                    EllipsisMenu(size: 18) { post.menuActions() }
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
                
                InfoStackView(post: post, readouts: [.created, .score, .comment], showColor: true)
            }
            .frame(maxWidth: .infinity)
            
            if thumbnailLocation == .right {
                ThumbnailImageView(post: post, blurred: post.nsfw, size: .standard)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
