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
    @Setting(\.post_showCreator) private var alwaysShowCreator
    @Setting(\.person_showAvatar) private var showPersonAvatar
    @Setting(\.community_showAvatar) private var showCommunityAvatar
    @Setting(\.safety_blurNsfw) var blurNsfw
    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    @Setting(\.interactionBar_post) var postInteractionBar
    @Setting(\.interactionBar_postReport) var postReportInteractionBar
    @Setting(\.interactionBar_alternateReportLayout) var alternateInteractionBarLayoutForReports
    
    @Environment(AppState.self) private var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.communityContext) private var communityContext
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.reportContext) private var reportContext: Report?

    let post: Post
    let isPostPage: Bool
    let favoredLink: PostViewNavigationLink?
    
    init(
        post: Post,
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
            .background(.themedSecondaryGroupedBackground)
            .environment(\.postContext, post)
    }
    
    var content: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    switch topNavigationLink {
                    case .community: communityLink
                    case .creator: personLink
                    }
                    
                    Spacer()
                    
                    if !isPostPage, differentiateWithoutColor, readPostIndicator == .checkmark {
                        ReadCheck(read: post.read)
                    }
                    
                    if post.nsfw {
                        Image(icon: .lemmy.nsfwTag)
                            .foregroundStyle(.themedWarning)
                    }
                    
                    if !isPostPage {
                        PostEllipsisMenus(post: post)
                    }
                }
                
                LargePostBodyView(post: post, isPostPage: isPostPage, shouldBlur: shouldBlur)
                
                if (alwaysShowCreator && communityContext == nil) || isPostPage {
                    personLink
                }
                
                if showDivider {
                    Divider().padding(.horizontal, -Constants.main.standardSpacing)
                }
            }
            .padding([.top, .horizontal], Constants.main.standardSpacing)
            
            InteractionBarView(
                appState: appState,
                post: post,
                configuration: interactionBarConfiguration,
                navigation: navigation,
                commentTreeTracker: commentTreeTracker,
                communityContext: communityContext,
                reportContext: reportContext
            )
        }
    }
    
    var interactionBarConfiguration: PostBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return postReportInteractionBar
        }
        return postInteractionBar
    }
    
    var showDivider: Bool {
        !(post.content?.isEmpty ?? true) || post.poll != nil
    }
    
    @ViewBuilder
    var personLink: some View {
        ExpectedView(post.creator) { creator in
            FullyQualifiedLinkView(creator, labelStyle: .medium)
        } placeholder: {
            Text(verbatim: .personPlaceholder).redacted(reason: .placeholder)
        }
    }
    
    @ViewBuilder
    var communityLink: some View {
        ExpectedView(post.community) { community in
            FullyQualifiedLinkView(community, labelStyle: .medium)
        } placeholder: {
            Text(verbatim: .communityPlaceholder)
                .redacted(reason: .placeholder)
        }
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
//        LargePostView(
//            post: Post2.mock(.generic),
//            isPostPage: true,
//            favoredLink: nil
//        )
//    }
// #endif
