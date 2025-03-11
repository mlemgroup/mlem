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
    @Setting(\.alternateInteractionBarLayoutForReports) var alternateInteractionBarLayoutForReports
    
    @Environment(AppState.self) private var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.communityContext) private var communityContext
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.reportContext) private var reportContext: Report?

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
            .background(.themedSecondaryGroupedBackground)
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
                        .foregroundStyle(.themedWarning)
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
                appState: appState,
                post: post,
                configuration: interactionBarConfiguration,
                navigation: navigation,
                commentTreeTracker: commentTreeTracker,
                communityContext: communityContext,
                reportContext: reportContext
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
        }
    }
    
    var interactionBarConfiguration: PostBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return InteractionBarTracker.main.postReportInteractionBar
        }
        return InteractionBarTracker.main.postInteractionBar
    }
    
    var showDivider: Bool {
        !(post.content?.isEmpty ?? true)
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(post.creator_, labelStyle: .medium, blurred: shouldBlur)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(post.community_, labelStyle: .medium, blurred: shouldBlur)
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
        LargePostView(
            post: Post2.mock(.generic),
            isPostPage: true,
            favoredLink: nil
        )
    }
#endif
