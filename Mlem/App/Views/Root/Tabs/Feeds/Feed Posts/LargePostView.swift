//
//  LargePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct LargePostView: View {
    @Setting(\.showPostCreator) private var showCreator
    @Setting(\.showPersonAvatar) private var showPersonAvatar
    @Setting(\.showCommunityAvatar) private var showCommunityAvatar
    @Setting(\.blurNsfw) var blurNsfw
    
    @Environment(Palette.self) private var palette: Palette
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(\.communityContext) private var communityContext
    
    let post: any Post1Providing
    var isPostPage: Bool = false
    
    var shouldBlur: Bool {
        switch blurNsfw {
        case .always: post.nsfw
        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
        case .never: false
        }
    }
    
    var body: some View {
        content
            .padding(.vertical, Constants.main.standardSpacing)
            .background(palette.secondaryGroupedBackground)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                if communityContext == nil || isPostPage {
                    communityLink
                } else {
                    personLink
                }
                
                Spacer()
                
                if post.nsfw {
                    Image(Icons.nsfwTag)
                        .foregroundStyle(palette.warning)
                }

                if !isPostPage {
                    PostEllipsisMenus(post: post)
                }
            }
            .padding(.horizontal, Constants.main.standardSpacing)
            
            LargePostBodyView(post: post, isPostPage: isPostPage, shouldBlur: shouldBlur)
                .padding(.horizontal, Constants.main.standardSpacing)
            
            if (showCreator && communityContext == nil) || isPostPage {
                personLink
                    .padding(.horizontal, Constants.main.standardSpacing)
            }
            
            if showDivider { Divider() }
            
            InteractionBarView(
                post: post,
                configuration: InteractionBarTracker.main.postInteractionBar,
                commentTreeTracker: commentTreeTracker,
                communityContext: communityContext
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
        }
    }
    
    var showDivider: Bool {
        !(post.content?.isEmpty ?? true)
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(entity: post.creator_, labelStyle: .medium, showAvatar: showPersonAvatar, blurred: shouldBlur)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(entity: post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar, blurred: shouldBlur)
    }
}
