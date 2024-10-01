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
        typealias Value = [URL?: Anchor<CGPoint>]

        static var defaultValue: Value { [:] }

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.merge(nextValue()) { $1 }
        }
    }

    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.jumpButton) var jumpButton
    @Setting(\.compactComments) var compactComments
    
    var post: (any PostStubProviding)?
    let isLoading: Bool
    let highlightedComment: (any CommentStubProviding)?
    let content: Content
    
    @Binding var tracker: CommentTreeTracker?
    @State var scrollTargetedComment: (any CommentStubProviding)?

    @State var scrolledToscrollTargetedComment: Bool = false
    @State var jumpButtonTarget: URL?
    @State var topVisibleItem: URL?
    
    init(
        post: (any PostStubProviding)?,
        isLoading: Bool,
        tracker: Binding<CommentTreeTracker?>,
        highlightedComment: (any CommentStubProviding)? = nil,
        scrollTargetedComment: (any CommentStubProviding)? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.post = post
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
                            // post.markRead()
                            await tracker.load()
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            VStack {
                if showLoadingSymbol {
                    ZStack {
                        palette.background
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
                    LazyVStack(
                        alignment: .leading,
                        spacing: compactComments ? Constants.main.halfSpacing : Constants.main.standardSpacing
                    ) {
                        LargePostView(post: post, isExpanded: true)
                            .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
                            .id(post.actorId)
                            .transition(.opacity)
                            .animation(.easeOut(duration: 0.1), value: type(of: post).tierNumber)
                            .anchorPreference(
                                key: AnchorsKey.self,
                                value: .center
                            ) { [post.actorId: $0] }
                            .padding(.horizontal, Constants.main.standardSpacing)
                        content
                        if let tracker {
                            commentTree(tracker: tracker)
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: scrollTargetedComment?.actorId)
                    .padding(.bottom, 80)
                    .id(tracker?.proposedDepthOffset)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: tracker?.proposedDepthOffset)
                }
                .onChange(of: tracker?.loadingState, initial: true) {
                    if tracker?.loadingState == .done, let scrollTargetedComment {
                        // Without a slight delay here, `scrollTo` can sometimes fail. I'm not sure why this is.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(scrollTargetedComment.actorId, anchor: .center)
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
                    if jumpButton != .none, (tracker?.comments.count ?? 0) > 1 {
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
        .toolbar {
            if let tracker {
                sortPicker(tracker: tracker)
            }
            if isLoading || post.shouldShowLoadingSymbol() {
                ProgressView()
            } else {
                ToolbarEllipsisMenu(post.allMenuActions(expanded: true))
            }
        }
        .environment(tracker)
    }
    
    @ViewBuilder
    func commentTree(tracker: CommentTreeTracker) -> some View {
        ForEach(tracker.comments.itemTree(), id: \.hashValue) { item in
            Group {
                switch item {
                case let .comment(comment):
                    CommentView(
                        comment: comment,
                        highlight: [scrollTargetedComment?.actorId, highlightedComment?.actorId].contains(comment.actorId),
                        depthOffset: tracker.proposedDepthOffset
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000 - Double(comment.depth))
                    .anchorPreference(
                        key: AnchorsKey.self,
                        value: .center
                    ) { [comment.actorId: $0] }
                    .padding(.leading, CGFloat(comment.depth - tracker.proposedDepthOffset) * 10)
                    .id(comment.actorId)
                case let .unloadedComments(comment, _):
                    Button {
                        navigation.push(.comment(comment, showViewPostButton: false))
                    } label: {
                        HStack {
                            CommentBarView(depth: comment.depth + 1)
                            HStack {
                                Text("More Replies")
                                Image(systemName: Icons.forward)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundStyle(palette.accent)
                        }
                        .background(
                            palette.secondaryGroupedBackground,
                            in: .rect(cornerRadius: Constants.main.standardSpacing)
                        )
                    }
                    .padding(.leading, CGFloat(comment.depth + 1 - tracker.proposedDepthOffset) * 10)
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    func sortPicker(tracker: CommentTreeTracker) -> some View {
        Picker(
            "Sort",
            selection: Binding(get: { tracker.sort }, set: {
                tracker.sort = $0
                tracker.clear()
                Task { await tracker.load() }
            })
        ) {
            ForEach(ApiCommentSortType.allCases, id: \.self) { item in
                if (post?.api.fetchedVersion ?? .infinity) >= item.minimumVersion {
                    Label(String(localized: item.label), systemImage: item.systemImage)
                }
            }
        }
    }
}
