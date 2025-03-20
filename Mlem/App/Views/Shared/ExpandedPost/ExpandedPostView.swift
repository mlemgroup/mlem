//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Sjmarf on 03/09/2024.
//

import MlemMiddleware
import SwiftUI

struct ExpandedPostView<Content: View>: View {
    struct AnchorsKey: PreferenceKey {
        // swiftlint:disable:next nesting
        typealias Value = [ActorIdentifier?: Anchor<CGPoint>]

        static var defaultValue: Value { [:] }

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.merge(nextValue()) { $1 }
        }
    }

    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.jumpButton) var jumpButton
    @Setting(\.compactComments) var compactComments
    @Setting(\.tapPostsToCollapse) var tapPostsToCollapse
    
    var post: (any PostStubProviding)?
    var contentLoaderError: Error?
    let isLoading: Bool
    let highlightedComment: (any CommentStubProviding)?
    let content: Content
    
    @Binding var tracker: CommentTreeTracker?
    @State var scrollTargetedComment: (any CommentStubProviding)?

    @State var scrolledToscrollTargetedComment: Bool = false
    @State var jumpButtonTarget: ActorIdentifier?
    @State var topVisibleItem: ActorIdentifier?
    @State var postCollapsed: Bool = false
    
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
                        } else if (post.commentCount_ ?? -1) == 0 {
                            noCommentsView
                                .padding(.top, Constants.main.doubleSpacing)
                        } else if let tracker {
                            switch tracker.loadingState {
                            case .done:
                                LazyVStack(spacing: 0) {
                                    commentTree(tracker: tracker)
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
                .overlay {
                    if jumpButton != .none, (tracker?.nodes.count ?? 0) > 1 {
                        JumpButtonView(onShortPress: scrollToNextComment, onLongPress: scrollToPreviousComment)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: jumpButton.alignment
                            )
                    }
                }
                .onPreferenceChange(AnchorsKey.self) { anchors in
                    topVisibleItem = topCommentRow(of: anchors, in: geo)
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
        .quickSwipes(post.swipeActions(appState: appState, behavior: .standard, commentTreeTracker: tracker))
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
