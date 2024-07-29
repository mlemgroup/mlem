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
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
            .background(palette.background)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
            if thumbnailLocation == .left {
                ThumbnailImageView(post: post, blurred: post.nsfw)
            }
            
            VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                HStack(spacing: 4) {
                    if communityContext != nil {
                        NavigationLink(value: NavigationPage.profile) {
                            FullyQualifiedLabelView(entity: post.creator_, labelStyle: .small, showAvatar: false)
                        }
                    } else {
                        FullyQualifiedLabelView(entity: post.community_, labelStyle: .small, showAvatar: false)
                    }
                    Spacer()
                    
                    if post.nsfw {
                        Image(Icons.nsfwTag)
                            .foregroundStyle(palette.warning)
                            .imageScale(.small)
                    }
                    
                    Image(systemName: Icons.moderation)
                        .imageScale(.small)
                    
                    EllipsisMenu(actions: post.menuActions(), size: 18)
                }
                .padding(.bottom, -2)
  
                post.taggedTitle(communityContext: communityContext)
                    .imageScale(.small)
                    .font(.subheadline)
                
                if let host = post.linkHost {
                    PostLinkHostView(host: host)
                        .font(.caption)
                }
                
                InfoStackView(post: post, readouts: [.created, .score, .comment], showColor: true)
            }
            .frame(maxWidth: .infinity)
            
            if thumbnailLocation == .right {
                ThumbnailImageView(post: post, blurred: post.nsfw)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
