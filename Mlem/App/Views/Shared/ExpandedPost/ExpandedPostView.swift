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
    var furthestVisitedComment: ActorIdentifier?
    var isAtPost: Bool = true
}

struct ExpandedPostView<Content: View>: View {
    @Environment(AppState.self) var appState
    @Environment(ExpandedPostHistoryTracker.self) var expandedPostHistoryTracker
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.comment_jumpButton) var jumpButton
    @Setting(\.comment_compact) var compactComments
    @Setting(\.post_gestures_tapToCollapse) var tapPostsToCollapse
    @Setting(\.comment_gestures_tapToCollapse) var tapCommentsToCollapse
    @Setting(\.interactionBar_post) var postInteractionBar
    @Setting(\.interactionBar_comment) var commentInteractionBar

    @State var post: Post
    let highlightedComment: Comment?
    let content: Content
    @State var isLoading: Bool = false
    
    @Binding var tracker: CommentTreeTracker
    @State var scrollTargetedComment: Comment?

    @State var scrolledToScrollTargetedComment: Bool = false
    @State var jumpButtonTarget: ActorIdentifier?
    @State var topVisibleItem: TopVisibleItemContainer = .init()
    @State var postCollapsed: Bool = false
    
    @State var previousVisitRecord: PreviousVisitRecord?
    
    init(
        post: Post,
        tracker: Binding<CommentTreeTracker>?,
        highlightedComment: Comment? = nil,
        scrollTargetedComment: Comment? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.post = post
        self.highlightedComment = highlightedComment
        self.content = content()
        self._tracker = tracker ?? .constant(.init(root: .post(post)))
        self._scrollTargetedComment = .init(wrappedValue: scrollTargetedComment)
    }
    
    var body: some View {
        // Using a `ZStack` here rather than `if`/`else` because there needs to
        // be a delay between the `content()` appearing and calling `scrollTo`
        VStack {
            viewContent
                .themedGroupedBackground()
                .reloadOnAccountSwitch(entity: $post, isLoading: $isLoading) { newPost in
                    tracker.root = .post(newPost)
                    tracker.loadingState = .idle
                    Task {
                        await tracker.load(ensuringPresenceOf: scrollTargetedComment)
                    }
                }
                .externalApiWarning(entity: post, isLoading: isLoading)
                .task {
                    await tracker.load(ensuringPresenceOf: scrollTargetedComment)
                    if post.api == appState.firstApi {
                        post.updateRead(true)
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .conditionalNavigationTitle(post.community.value?.name ?? "")
        .overlay {
            VStack {
                if showLoadingSymbol {
                    ZStack {
                        palette.groupedBackground.primary
                            .ignoresSafeArea()
                        ProgressView()
                            .tint(.secondary)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.1), value: showLoadingSymbol)
        }
        .refreshable {
            _ = await Task { @MainActor in
                do {
                    try await post.upgrade() // this is identical to refresh
                    await tracker.refresh()
                } catch {
                    handleError(error)
                }
            }.value
        }
    }
    
    @ViewBuilder
    var viewContent: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                FancyScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 0
                    ) {
                        postView(post, scrollProxy: proxy)
                            .padding(.horizontal, Constants.main.standardSpacing)
                        
                        content
                            .padding(.top, compactComments ? Constants.main.halfSpacing : Constants.main.standardSpacing)
                        
                        if let errorDetails = tracker.errorDetails {
                            ErrorView(errorDetails)
                                .frame(maxWidth: .infinity)
                        } else if hasNoComments {
                            noCommentsView
                                .padding(.top, Constants.main.doubleSpacing)
                        } else {
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
                    .animation(.easeInOut(duration: 0.1), value: tracker.loadingState == .loading)
                    .animation(.easeInOut(duration: 0.1), value: tracker.errorDetails == nil)
                    .animation(.easeInOut(duration: 0.4), value: scrollTargetedComment?.actorId)
                    .padding(.bottom, 80)
                    .id(tracker.proposedDepthOffset)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: tracker.proposedDepthOffset)
                }
                .onChange(of: tracker.loadingState, initial: true) {
                    if tracker.loadingState == .done, let scrollTargetedComment {
                        // Without a slight delay here, `scrollTo` can sometimes fail. I'm not sure why this is.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(scrollTargetedComment.actorId, anchor: .center)
                            scrolledToScrollTargetedComment = true
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
                    JumpButtonsView(
                        showJumpButton: (tracker.nodes.count) > 1,
                        topVisibleItem: topVisibleItem,
                        scrollToLastVisitedPosition: showScrollToLastVisitButton(post: post) ? scrollToLastVisitedPosition : nil,
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
                .toolbar { toolbarContent(post: post, scrollProxy: proxy) }
            }
        }
        .environment(tracker)
        .environment(\.feedContext, .post)
    }
    
    @ViewBuilder
    func toolbarContent(post: Post, scrollProxy: ScrollViewProxy) -> some View {
        sortPicker(tracker: tracker)
        if post.shouldShowLoadingSymbol() {
            ProgressView()
        } else {
            ToolbarEllipsisMenu {
                PostEllipsisMenuContent(post: post, type: [.basic, .moderator])
                if !tapPostsToCollapse {
                    Section {
                        Button(
                            postCollapsed ? "Expand Post" : "Collapse Post",
                            icon: postCollapsed ? .general.expand : .general.collapse
                        ) {
                            togglePostCollapsed(post: post, scrollProxy: scrollProxy)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func postView(_ post: Post, scrollProxy: ScrollViewProxy) -> some View {
        Group {
            if postCollapsed {
                HStack {
                    post.taggedTitle(communityContext: post.community.value)
                        .font(.headline)
                        .symbolVariant(.fill)
                        .background(.themedSecondaryGroupedBackground)
                    Spacer()
                    Image(icon: .general.expand)
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
        .quickSwipes(post: post, configuration: postInteractionBar)
        .contextMenu {
            post.allMenuActions(
                appState: appState,
                showAllActions: false,
                navigation: navigation,
                commentTreeTracker: tracker
            )
        }
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .onTapGesture {
            if tapPostsToCollapse || postCollapsed {
                togglePostCollapsed(post: post, scrollProxy: scrollProxy)
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
    @Setting(\.comment_jumpButton) var jumpButton
    
    var showJumpButton: Bool
    var topVisibleItem: TopVisibleItemContainer
    
    var scrollToLastVisitedPosition: (() -> Void)?
    var scrollToNextComment: () -> Void
    var scrollToPreviousComment: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if let scrollToLastVisitedPosition, topVisibleItem.isAtPost, showJumpButton {
                JumpButtonView(
                    icon: .lemmy.jumpToLastPositionButton,
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
