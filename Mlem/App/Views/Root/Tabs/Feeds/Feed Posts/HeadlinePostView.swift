//
//  HeadlinePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct HeadlinePost: View {
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    @AppStorage("user.showAvatar") var showUserAvatar: Bool = true
    @AppStorage("community.showAvatar") var showCommunityAvatar: Bool = false
    
    @Environment(\.communityContext) var communityContext: (any Community3Providing)?
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                FullyQualifiedLabelView(entity: post.community_, showAvatar: showCommunityAvatar, instanceLocation: .bottom)
                
                Spacer()
                
                EllipsisMenu(actions: post.menuActions, size: 24)
            }
            
            HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
                if thumbnailLocation == .left {
                    ThumbnailImageView(post: post)
                }
                
                post.taggedTitle(communityContext: communityContext)
                    .font(.headline)
                    .imageScale(.small)
                
//                Image("nsfw")
                
                if thumbnailLocation == .right {
                    ThumbnailImageView(post: post)
                }
            }
            
            FullyQualifiedLabelView(entity: post.creator_, showAvatar: showUserAvatar, instanceLocation: .bottom)
        }
    }
}
