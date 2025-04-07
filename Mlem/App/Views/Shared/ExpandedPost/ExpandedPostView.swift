//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Sjmarf on 03/09/2024.
//

import MlemMiddleware
import SwiftUI

@Observable
class TopVisibleItemContainer {
    // This doesn't need to trigger view updates
    @ObservationIgnored var wrappedValue: ActorIdentifier?
    var isAtPost: Bool = true
}

struct ExpandedPostView<Content: View>: View {
    @Environment(AppState.self) var appState
    @Environment(ExpandedPostHistoryTracker.self) var expandedPostHistoryTracker
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.jumpButton) var jumpButton
    @Setting(\.compactComments) var compactComments
    @Setting(\.tapPostsToCollapse) var tapPostsToCollapse
    @Setting(\.tapCommentsToCollapse) var tapCommentsToCollapse

    var post: (any PostStubProviding)?
    var contentLoaderError: Error?
    let isLoading: Bool
    let highlightedComment: (any CommentStubProviding)?
    let content: Content
    
    @Binding var tracker: CommentTreeTracker?
    @State var scrollTargetedComment: (any CommentStubProviding)?

    @State var scrolledToscrollTargetedComment: Bool = false
    @State var jumpButtonTarget: ActorIdentifier?
    @State var topVisibleItem: TopVisibleItemContainer = .init()
    @State var postCollapsed: Bool = false
    
    @State var previousVisitRecord: PreviousVisitRecord?
    
    init(
        post: (any PostStubProviding)?,
        contentLoaderError: Error?,
        isLoading: Bool,
        tracker: Binding<CommentTreeTracker?>,
        highlightedComment: (any CommentStubProviding)? = nil,
        scrollTargetedComment: (any CommentStubProviding)? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.post = post
        self.contentLoaderError = contentLoaderError
        self.isLoading = isLoading
        self.highlightedComment = highlightedComment
        self.content = content()
        self._tracker = tracker
        self._scrollTargetedComment = .init(wrappedValue: scrollTargetedComment)
    }
    
    var body: some View {
        // Using a `ZStack` here rather than `if`/`else` because there needs to
        // be a delay between the `content()` appearing and calling `scrollTo`
        VStack {
            if let post = post as? any Post {
                content(post: post, isLoading: isLoading)
                    .externalApiWarning(entity: post, isLoading: isLoading)
                    .task(id: tracker == nil) {
                        if let tracker, post.api == appState.firstApi, tracker.loadingState == .idle {
                            post.markRead()
                        }
                    }
            } else if let contentLoaderError {
                ErrorView(.init(error: contentLoaderError))
            } else {
                ProgressView()
                    .tint(.themedSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            VStack {
                if showLoadingSymbol {
                    ZStack {
                        palette.background.primary
                            .ignoresSafeArea()
                        ProgressView()
                            .tint(.secondary)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.1), value: showLoadingSymbol)
        }
    }
    
    // swiftlint:disable:next function_body_length
    @ViewBuilder func content(post: any Post, isLoading: Bool) -> some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                FancyScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 0
                    ) {
                        postView(post)
                            .padding(.horizontal, Constants.main.standardSpacing)
                        content
                            .padding(.top, compactComments ? Constants.main.halfSpacing : Constants.main.standardSpacing)
                        
                        if let errorDetails = tracker?.errorDetails {
                            ErrorView(errorDetails)
                                .frame(maxWidth: .infinity)
                        } else if let contentLoaderError {
                            ErrorView(.init(error: contentLoaderError))
                                .frame(maxWidth: .infinity)
                        } else if (post.commentCount_ ?? -1) == 0 {
                            noCommentsView
                                .padding(.top, Constants.main.doubleSpacing)
                        } else if let tracker {
                            switch tracker.loadingState {
                            case .done:
                                LazyVStack(spacing: 0) {
                                    commentTree(tracker: tracker, scrollProxy: proxy)
                                }
                                .geometryGroup()
                            default:
                                ProgressView()
                                    .tint(.themedSecondary)
                                    .padding(.top, 50)
                                    // This prevents the tab bar going transparent whilst the comments are loading
                                    .padding(.bottom, 500)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.1), value: (tracker?.loadingState ?? .loading) == .loading)
                    .animation(.easeInOut(duration: 0.1), value: tracker?.errorDetails == nil)
                    .animation(.easeInOut(duration: 0.4), value: scrollTargetedComment?.actorId_)
                    .padding(.bottom, 80)
                    .id(tracker?.proposedDepthOffset ?? 0)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: tracker?.proposedDepthOffset)
                }
                .onChange(of: tracker?.loadingState, initial: true) {
                    if tracker?.loadingState == .done, let scrollTargetedComment {
                        // Without a slight delay here, `scrollTo` can sometimes fail. I'm not sure why this is.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(scrollTargetedComment.actorId_, anchor: .center)
                            scrolledToscrollTargetedComment = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.scrollTargetedComment = nil
                        }
                    }
                }
                .onChange(of: jumpButtonTarget) {
                    if let jumpButtonTarget {
                        withAnimation {
                            proxy.scrollTo(jumpButtonTarget, anchor: .top)
                        }
                        self.jumpButtonTarget = nil
                    }
                }
                .overlay(alignment: jumpButton.alignment) {
                    let shouldShowLastVisitButton = (previousVisitRecord?.isRevisit ?? false) && (post.commentCount_ ?? 0) > 10
                    JumpButtonsView(
                        showJumpButton: (tracker?.nodes.count ?? 0) > 1,
                        topVisibleItem: topVisibleItem,
                        scrollToLastVisitedPosition: shouldShowLastVisitButton ? scrollToLastVisitedPosition : nil,
                        scrollToNextComment: scrollToNextComment,
                        scrollToPreviousComment: scrollToPreviousComment
                    )
                }
                .onPreferenceChange(AnchorsKey.self) { updateAnchors($0, in: geo) }
                .onAppear {
                    if previousVisitRecord == nil {
                        if let actorId = expandedPostHistoryTracker.retrieve(for: post.actorId) {
                            previousVisitRecord = .revisit(topVisibleCommentAtLastVisit: actorId)
                        } else {
                            previousVisitRecord = .firstVisit
                        }
                    }
                }
            }
        }
        .toolbar { toolbarContent(post: post, isLoading: isLoading) }
        .environment(tracker)
        .environment(\.feedContext, .post)
    }
    
    @ViewBuilder
    func toolbarContent(post: any Post, isLoading: Bool) -> some View {
        if let tracker {
            sortPicker(tracker: tracker)
        }
        if isLoading || post.shouldShowLoadingSymbol() {
            ProgressView()
        } else {
            ToolbarEllipsisMenu {
                MenuButtons {
                    post.allMenuActions(
                        appState: appState,
                        expanded: true,
                        navigation: navigation,
                        commentTreeTracker: tracker
                    )
                }
                if !tapPostsToCollapse {
                    Section {
                        Button(
                            postCollapsed ? "Expand Post" : "Collapse Post",
                            systemImage: postCollapsed ? Icons.expandComment : Icons.collapseComment,
                            action: togglePostCollapsed
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func postView(_ post: any Post) -> some View {
        Group {
            if postCollapsed {
                HStack {
                    post.taggedTitle(communityContext: post.community_)
                        .font(.headline)
                        .background(.themedSecondaryGroupedBackground)
                    Spacer()
                    Image(systemName: Icons.expandComment)
                        .frame(height: 10)
                }
                .imageScale(.small)
                .padding(Constants.main.standardSpacing)
                .background(.themedSecondaryGroupedBackground)
            } else {
                LargePostView(post: post, isPostPage: true)
            }
        }
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .quickSwipes(
            post: post,
            configuration: InteractionBarTracker.main.postInteractionBar,
            behavior: .standard
        )
        .contextMenu {
            post.allMenuActions(
                appState: appState,
                showAllActions: false,
                navigation: navigation,
                commentTreeTracker: tracker
            )
        }
        .paletteBorder(cornerRadius: PostSize.large.swipeBehavior.cornerRadius)
        .onTapGesture {
            if tapPostsToCollapse || postCollapsed {
                togglePostCollapsed()
            }
        }
        .id(post.actorId)
        .transition(.opacity)
        .animation(.easeOut(duration: 0.1), value: type(of: post).tierNumber)
        .anchorPreference(
            key: AnchorsKey.self,
            value: .center
        ) { [post.actorId: $0] }
    }
}

private struct JumpButtonsView: View {
    @Setting(\.jumpButton) var jumpButton
    
    var showJumpButton: Bool
    var topVisibleItem: TopVisibleItemContainer
    
    var scrollToLastVisitedPosition: (() -> Void)?
    var scrollToNextComment: () -> Void
    var scrollToPreviousComment: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if let scrollToLastVisitedPosition, topVisibleItem.isAtPost, showJumpButton {
                JumpButtonView(
                    systemImage: Icons.jumpToLastPositionButton,
                    onShortPress: scrollToLastVisitedPosition,
                    onLongPress: nil
                )
            }
            if jumpButton != .none, showJumpButton {
                JumpButtonView(
                    onShortPress: scrollToNextComment,
                    onLongPress: scrollToPreviousComment
                )
            }
        }
        .padding(Constants.main.standardSpacing)
        .animation(.default, value: topVisibleItem.isAtPost)
    }
}
