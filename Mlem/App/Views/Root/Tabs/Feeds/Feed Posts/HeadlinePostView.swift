//
//  HeadlinePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct HeadlinePostView<EmbeddedContent: View>: View {
    @Setting(\.thumbnailLocation) var thumbnailLocation
    @Setting(\.showPostCreator) var showCreator
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    @Setting(\.blurNsfw) var blurNsfw
    
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(Palette.self) var palette: Palette
    
    let post: any Post1Providing
    let embeddedContent: EmbeddedContent
    
    init(post: any Post1Providing, @ViewBuilder embeddedContent: () -> EmbeddedContent = { EmptyView() }) {
        self.post = post
        self.embeddedContent = embeddedContent()
    }
    
    var blurred: Bool {
        switch blurNsfw {
        case .always: post.nsfw
        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
        case .never: false
        }
    }
    
    var body: some View {
        contentView
            .padding(Constants.main.standardSpacing)
            .background(palette.secondaryGroupedBackground)
            .environment(\.postContext, post)
    }
    
    var contentView: some View {
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
                
                PostEllipsisMenus(post: post)
            }
            
            HStack(alignment: .top, spacing: Constants.main.standardSpacing) {
                if thumbnailLocation == .left {
                    ThumbnailImageView(
                        post: post,
                        blurred: blurred,
                        size: .standard,
                        frame: .init(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                    )
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
                    ThumbnailImageView(
                        post: post,
                        blurred: blurred,
                        size: .standard,
                        frame: .init(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                    )
                }
            }
            
            if showCreator, communityContext == nil {
                personLink
            }
            
            embeddedContent
            
            InteractionBarView(
                post: post,
                configuration: InteractionBarTracker.main.postInteractionBar,
                commentTreeTracker: commentTreeTracker,
                communityContext: communityContext
            )
            .padding(.horizontal, 2)
            .padding(.vertical, 5)
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
