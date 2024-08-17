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
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.showPostCreator) var showCreator
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    
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
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                if communityContext == nil {
                    communityLink
                } else {
                    personLink
                }
                
                Spacer()
                
                if post.nsfw {
                    Image(Icons.nsfwTag)
                        .foregroundStyle(palette.warning)
                }
                
                EllipsisMenu(size: 24) { post.menuActions() }
            }
            
            HStack(alignment: .top, spacing: Constants.main.standardSpacing) {
                if thumbnailLocation == .left {
                    ThumbnailImageView(post: post, blurred: post.nsfw, size: .standard)
                }
  
                VStack(alignment: .leading, spacing: Constants.main.halfSpacing) {
                    post.taggedTitle(communityContext: communityContext)
                        .foregroundStyle((post.read_ ?? false) ? palette.secondary : palette.primary)
                        .font(.headline)
                        .imageScale(.small)
                    
                    if let host = post.linkHost {
                        PostLinkHostView(host: host)
                            .font(.subheadline)
                    }
                }
                
                if thumbnailLocation == .right {
                    Spacer()
                    ThumbnailImageView(post: post, blurred: post.nsfw, size: .standard)
                }
            }
            
            if showCreator, communityContext == nil {
                personLink
            }
            
            InteractionBarView(
                post: post,
                configuration: .init(
                    leading: [.counter(.score)],
                    trailing: [.action(.save), .action(.reply)],
                    readouts: [.created, .score, .comment]
                )
            )
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(entity: post.creator_, labelStyle: .medium, showAvatar: showPersonAvatar)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(entity: post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar)
    }
}
