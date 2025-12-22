//
//  DevPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-18.
//

import SwiftUI
import MlemMiddleware
import ComponentViews

struct DevPostView: View {
    @State var postModel: UnifiedPostModel
    
    init(post: any Post1Providing) {
        self.postModel = .init(api: post.api, url: post.url())
    }
    
    var animationHashValue: Int {
        var hasher = Hasher()
        hasher.combine(postModel.title != nil ? 1 : 0)
        return hasher.finalize()
    }
    
    var body: some View {
        ExpectedText(postModel.title)
    }
}

struct DevLargePostView: View {
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
    
    let post: UnifiedPostModel
    let isPostPage: Bool
    let favoredLink: PostViewNavigationLink?
    
    init(
        post: UnifiedPostModel,
        isPostPage: Bool = false,
        favoredLink: PostViewNavigationLink? = nil
    ) {
        self.post = post
        self.isPostPage = isPostPage
        self.favoredLink = favoredLink
    }
    
//    var shouldBlur: Bool {
//        switch blurNsfw {
//        case .always: post.nsfw
//        case .outsideCommunity: post.nsfw && !(communityContext?.nsfw ?? false)
//        case .never: false
//        }
//    }
    
    var topNavigationLink: PostViewNavigationLink {
        if let favoredLink { return favoredLink }
        return communityContext == nil || isPostPage ? .community : .creator
    }
    
    var interactionBarConfiguration: PostBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return postReportInteractionBar
        }
        return postInteractionBar
    }
    
//    var showDivider: Bool {
//        !(post.content?.isEmpty ?? true)
//    }
    
    var body: some View {
        content
            .background(.themedSecondaryGroupedBackground)
            // .environment(\.postContext, post)
    }
    
    var content: some View {
        ExpectedText(post.title)
    }
    
//    var content: some View {
//        VStack(spacing: 0) {
//            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
//                HStack {
//                    switch topNavigationLink {
//                    case .community: communityLink
//                    case .creator: personLink
//                    }
//                    
//                    Spacer()
//                    
//                    if !isPostPage, differentiateWithoutColor, readPostIndicator == .checkmark, post.read_ ?? false {
//                        ReadCheck()
//                    }
//                    
//                    if post.nsfw {
//                        Image(icon: .lemmy.nsfwTag)
//                            .foregroundStyle(.themedWarning)
//                    }
//                    
//                    if !isPostPage {
//                        PostEllipsisMenus(post: post)
//                    }
//                }
//                
//                LargePostBodyView(post: post, isPostPage: isPostPage, shouldBlur: shouldBlur)
//                
//                if (alwaysShowCreator && communityContext == nil) || isPostPage {
//                    personLink
//                }
//                
//                if showDivider {
//                    Divider().padding(.horizontal, -Constants.main.standardSpacing)
//                }
//            }
//            .padding([.top, .horizontal], Constants.main.standardSpacing)
//            
//            InteractionBarView(
//                appState: appState,
//                post: post,
//                configuration: interactionBarConfiguration,
//                navigation: navigation,
//                commentTreeTracker: commentTreeTracker,
//                communityContext: communityContext,
//                reportContext: reportContext
//            )
//        }
//    }
//    
//    @ViewBuilder
//    var personLink: some View {
//        FullyQualifiedLinkView(post.creator_, labelStyle: .medium, blurred: shouldBlur)
//    }
//    
//    @ViewBuilder
//    var communityLink: some View {
//        FullyQualifiedLinkView(post.community_, labelStyle: .medium, blurred: shouldBlur)
//    }
}
