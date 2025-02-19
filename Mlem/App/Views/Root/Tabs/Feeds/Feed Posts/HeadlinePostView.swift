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
    @Setting(\.showPostCreator) var alwaysShowCreator
    @Setting(\.showPersonAvatar) var showPersonAvatar
    @Setting(\.showCommunityAvatar) var showCommunityAvatar
    @Setting(\.readPostIndicator) var readPostIndicator
    @Setting(\.alternateInteractionBarLayoutForReports) var alternateInteractionBarLayoutForReports

    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(Palette.self) var palette: Palette
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.reportContext) private var reportContext: Report?

    let post: any Post1Providing
    let embeddedContent: EmbeddedContent
    let favoredLink: PostViewNavigationLink?
    let requireConsistentHeight: Bool

    init(
        post: any Post1Providing,
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
            .padding(Constants.main.standardSpacing)
            .background(palette.secondaryGroupedBackground)
            .environment(\.postContext, post)
    }
    
    var contentView: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            HStack {
                switch topNavigationLink {
                case .community: communityLink
                case .creator: personLink
                }
                
                Spacer()
                
                if differentiateWithoutColor, readPostIndicator == .checkmark, post.read_ ?? false {
                    ReadCheck()
                }
                
                if post.nsfw {
                    Image(Icons.nsfwTag)
                        .foregroundStyle(palette.warning)
                }
                
                PostEllipsisMenus(post: post)
            }
            
            HeadlinePostBodyView(post: post, requireConsistentHeight: requireConsistentHeight)
            
            if alwaysShowCreator, communityContext == nil {
                personLink
            }
            
            embeddedContent
            
            InteractionBarView(
                post: post,
                configuration: interactionBarConfiguration,
                commentTreeTracker: commentTreeTracker,
                communityContext: communityContext,
                reportContext: reportContext
            )
            .padding(.horizontal, 2)
            .padding(.vertical, 5)
        }
    }
    
    @ViewBuilder
    var personLink: some View {
        FullyQualifiedLinkView(post.creator_, labelStyle: .medium)
    }
    
    @ViewBuilder
    var communityLink: some View {
        FullyQualifiedLinkView(post.community_, labelStyle: .medium)
    }
    
    var interactionBarConfiguration: PostBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return InteractionBarTracker.main.postReportInteractionBar
        }
        return InteractionBarTracker.main.postInteractionBar
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
        HeadlinePostView(post: Post2.mock(.generic))
    }
#endif
