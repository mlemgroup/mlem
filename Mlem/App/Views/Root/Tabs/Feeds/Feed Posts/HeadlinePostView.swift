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
    @Setting(\.post_showCreator) var alwaysShowCreator
    @Setting(\.person_showAvatar) var showPersonAvatar
    @Setting(\.community_showAvatar) var showCommunityAvatar
    @Setting(\.a11y_readPostIndicator) var readPostIndicator
    @Setting(\.interactionBar_post) var postInteractionBar
    @Setting(\.interactionBar_postReport) var postReportInteractionBar
    @Setting(\.interactionBar_alternateReportLayout) var alternateInteractionBarLayoutForReports

    @Environment(AppState.self) private var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.reportContext) private var reportContext: Report?

    let post: UnifiedPostModel
    let embeddedContent: EmbeddedContent
    let favoredLink: PostViewNavigationLink?
    let requireConsistentHeight: Bool

    init(
        post: UnifiedPostModel,
        favoredLink: PostViewNavigationLink? = nil,
        requireConsistentHeight: Bool = false,
        @ViewBuilder embeddedContent: () -> EmbeddedContent = { EmptyView() }
    ) {
        self.post = post
        self.favoredLink = favoredLink
        self.requireConsistentHeight = requireConsistentHeight
        self.embeddedContent = embeddedContent()
    }
    
    var topNavigationLink: PostViewNavigationLink {
        if let favoredLink { return favoredLink }
        return communityContext == nil ? .community : .creator
    }
    
    var body: some View {
        contentView
            .background(.themedSecondaryGroupedBackground)
            .environment(\.postContext, post)
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack {
                    switch topNavigationLink {
                    case .community: communityLink
                    case .creator: personLink
                    }
                    
                    Spacer()
                    
                    if differentiateWithoutColor, readPostIndicator == .checkmark {
                        ReadCheck(read: post.read)
                    }
                    
                    if post.nsfw {
                        Image(icon: .lemmy.nsfwTag)
                            .foregroundStyle(.themedWarning)
                    }
                    
                    PostEllipsisMenus(post: post)
                }
                
                HeadlinePostBodyView(post: post, requireConsistentHeight: requireConsistentHeight)
                
                if alwaysShowCreator, communityContext == nil {
                    personLink
                }
                
                embeddedContent
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
    
    @ViewBuilder
    var personLink: some View {
        ExpectedView(post.creator) { creator in
            FullyQualifiedLinkView(creator, labelStyle: .medium)
        } placeholder: {
            Text("creator@placeholder")
                .redacted(reason: .placeholder)
        }
    }
    
    @ViewBuilder
    var communityLink: some View {
        ExpectedView(post.community) { community in
            FullyQualifiedLinkView(community, labelStyle: .medium)
        } placeholder: {
            Text("community@placeholder")
                .redacted(reason: .placeholder)
        }
    }
    
    var interactionBarConfiguration: PostBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return postReportInteractionBar
        }
        return postInteractionBar
    }
}

// TODO: update mocks
//#if DEBUG
//    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
//        HeadlinePostView(post: Post2.mock(.generic))
//    }
//#endif
