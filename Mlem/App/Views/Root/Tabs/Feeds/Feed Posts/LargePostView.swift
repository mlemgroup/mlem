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
    @Setting(\.showPostCreator) private var alwaysShowCreator
    @Setting(\.showPersonAvatar) private var showPersonAvatar
    @Setting(\.showCommunityAvatar) private var showCommunityAvatar
    @Setting(\.blurNsfw) var blurNsfw
    @Setting(\.readPostIndicator) var readPostIndicator
    
    @Environment(Palette.self) private var palette: Palette
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(\.communityContext) private var communityContext
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    
    let post: any Post1Providing
    let isPostPage: Bool
    let favoredLink: PostViewNavigationLink?
    
    init(
        post: any Post1Providing,
        isPostPage: Bool = false,
        favoredLink: PostViewNavigationLink? = nil
    ) {
        self.post = post
        self.isPostPage = isPostPage
        self.favoredLink = favoredLink
    }
    
    var shouldBlur: Bool {
        switch blurNsfw {
        case .always: post.nsfw
        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
        case .never: false
        }
    }
    
    var topNavigationLink: PostViewNavigationLink {
        if let favoredLink { return favoredLink }
        return communityContext == nil || isPostPage ? .community : .creator
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
                switch topNavigationLink {
                case .community: communityLink
                case .creator: personLink
                }
                
                Spacer()
                
                if !isPostPage, differentiateWithoutColor, readPostIndicator == .checkmark, post.read_ ?? false {
                    ReadCheck()
                }
                
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
            
            if (alwaysShowCreator && communityContext == nil) || isPostPage {
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
            .padding(.vertical, Constants.main.barIconPadding)
        }
    }
    
    var showDivider: Bool {
        !(post.content?.isEmpty ?? true)
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(post.creator_, labelStyle: .medium, showAvatar: showPersonAvatar, blurred: shouldBlur)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(post.community_, labelStyle: .medium, showAvatar: showCommunityAvatar, blurred: shouldBlur)
    }
}
