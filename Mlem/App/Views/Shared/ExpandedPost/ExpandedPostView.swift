//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Sjmarf on 03/09/2024.
//

import MlemMiddleware
import SwiftUI

struct ExpandedPostView: View {
    struct AnchorsKey: PreferenceKey {
        // swiftlint:disable:next nesting
        typealias Value = [URL?: Anchor<CGPoint>]

        static var defaultValue: Value { [:] }

        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.merge(nextValue()) { $1 }
        }
    }

    @Environment(Palette.self) var palette
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    @Setting(\.jumpButton) var jumpButton
    @Setting(\.compactComments) var compactComments
    
    let post: AnyPost
    @State var tracker: CommentTreeTracker?
    @State var highlightedComment: (any CommentStubProviding)?
    @State var scrolledToHighlightedComment: Bool
    
    @State var jumpButtonTarget: URL?
    @State var topVisibleItem: URL?
    
    init(post: AnyPost, highlightedComment: (any CommentStubProviding)?) {
        self.post = post
        self._highlightedComment = .init(wrappedValue: highlightedComment)
        self._scrolledToHighlightedComment = .init(wrappedValue: highlightedComment == nil)
    }
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            // Using a `ZStack` here rather than `if`/`else` because there needs to
            // be a delay between the `content()` appearing and calling `scrollTo`
            VStack {
                if let post = proxy.entity, let tracker {
                    content(post: post, tracker: tracker, isLoading: proxy.isLoading)
                        .externalApiWarning(entity: post, isLoading: proxy.isLoading)
                        .task {
                            if post.api == appState.firstApi, tracker.loadingState == .idle {
                                post.markRead()
                                await load(tracker: tracker)
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
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let post = model.wrappedValue as? any Post {
                if let tracker {
                    tracker.root = .post(post)
                    tracker.loadingState = .idle
                    await load(tracker: tracker)
                } else {
                    tracker = .init(root: .post(post))
                }
            }
        }
        .background(palette.groupedBackground)
    }
    
    // swiftlint:disable:next function_body_length
    @ViewBuilder func content(post: any Post, tracker: CommentTreeTracker, isLoading: Bool) -> some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                FancyScrollView {
                    LazyVStack(
                        alignment: .leading,
                        spacing: compactComments ? Constants.main.halfSpacing : Constants.main.standardSpacing
                    ) {
                        LargePostView(post: post, isExpanded: true)
                            .clipShape(.rect(cornerRadius: 10))
                            .id(post.actorId)
                            .transition(.opacity)
                            .animation(.easeOut(duration: 0.1), value: post is any Post2Providing)
                            .anchorPreference(
                                key: AnchorsKey.self,
                                value: .center
                            ) { [post.actorId: $0] }
                            .padding(.horizontal, Constants.main.standardSpacing)
                        ForEach(tracker.comments.tree(), id: \.actorId) { comment in
                            CommentView(
                                comment: comment,
                                highlight: highlightedComment?.actorId == comment.actorId,
                                depthOffset: 0
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1000 - Double(comment.depth))
                            .anchorPreference(
                                key: AnchorsKey.self,
                                value: .center
                            ) { [comment.actorId: $0] }
                            .padding(.horizontal, Constants.main.standardSpacing)
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: highlightedComment?.actorId)
                    .padding(.bottom, 80)
                }
                .onChange(of: tracker.loadingState, initial: true) {
                    if tracker.loadingState == .done, let highlightedComment {
                        // Without a slight delay here, `scrollTo` can sometimes fail. I'm not sure why this is.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(highlightedComment.actorId, anchor: .center)
                            scrolledToHighlightedComment = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.highlightedComment = nil
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
                    if jumpButton != .none, tracker.comments.count > 1 {
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
            sortPicker(tracker: tracker)
            if isLoading {
                ProgressView()
            } else {
                ToolbarEllipsisMenu(post.menuActions())
            }
        }
        .environment(tracker)
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
                if (post.wrappedValue.api.fetchedVersion ?? .infinity) >= item.minimumVersion {
                    Label(String(localized: item.label), systemImage: item.systemImage)
                }
            }
        }
    }
}
