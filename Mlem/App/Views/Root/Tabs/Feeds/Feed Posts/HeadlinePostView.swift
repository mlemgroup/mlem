//
//  HeadlinePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct HeadlinePostView: View {
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    @AppStorage("post.showCreator") var showCreator: Bool = false
    @AppStorage("user.showAvatar") var showUserAvatar: Bool = true
    @AppStorage("community.showAvatar") var showCommunityAvatar: Bool = true
    
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
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                FullyQualifiedLabelView(entity: post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar)
                
                Spacer()
                
                if post.nsfw {
                    Image(Icons.nsfwTag)
                        .foregroundStyle(palette.warning)
                }
                
                EllipsisMenu(actions: post.menuActions, size: 24)
            }
            
            HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
                if thumbnailLocation == .left {
                    ThumbnailImageView(post: post)
                }
  
                VStack(alignment: .leading, spacing: AppConstants.halfSpacing) {
                    post.taggedTitle(communityContext: communityContext)
                        .font(.headline)
                        .imageScale(.small)
                    
                    if let host = post.linkHost {
                        PostLinkHostView(host: host)
                            .font(.subheadline)
                    }
                }
                
                if thumbnailLocation == .right {
                    Spacer()
                    ThumbnailImageView(post: post)
                }
            }
            
            if showCreator {
                FullyQualifiedLinkView(entity: post.creator_, labelStyle: .medium, showAvatar: showUserAvatar)
            }
        }
    }
}
