//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-12.
//

import Foundation
import MlemMiddleware
import SwiftUI

// This isn't a standalone page, but rather a component of other views.
struct CommentTreeView<Content: View>: View {
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
    
    @Setting(\.jumpButton) var jumpButton
    
    // These need to be `@State` despite being constant to avoid a view identity change, which cancels in-progress `scrollTo`
    @State var post: any Post
    @State var tracker: CommentTreeTracker
    @State var isLoading: Bool
    let depthOffset: Int
    let highlightCommentWithActorId: URL?
    let content: Content

    @State var scrollToCommentWithActorId: URL?
    @State var jumpButtonTarget: URL?
    @State var topVisibleItem: URL?
    
    init(
        post: any Post,
        tracker: CommentTreeTracker,
        highlightCommentWithActorId: URL? = nil,
        scrollToCommentWithActorId: URL? = nil,
        isLoading: Bool,
        depthOffset: Int = 0,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.highlightCommentWithActorId = highlightCommentWithActorId
        self.depthOffset = depthOffset
        self.post = post
        self.tracker = tracker
        self.isLoading = isLoading
        self.scrollToCommentWithActorId = scrollToCommentWithActorId
        self.content = content()
        print("INIT")
    }
    
    var body: some View {
        _ = Self._printChanges()
        return GeometryReader { geo in
            ScrollViewReader { proxy in
                FancyScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        LargePostView(post: post, isExpanded: true)
                            .id(post.actorId)
                            .transition(.opacity)
                            .animation(.easeOut(duration: 0.1), value: post is any Post2Providing)
                            .anchorPreference(
                                key: AnchorsKey.self,
                                value: .center
                            ) { [post.actorId: $0] }
                        Divider()
                        content
                        ForEach(tracker.comments.tree(), id: \.actorId) { comment in
                            CommentView(
                                comment: comment,
                                highlight: [scrollToCommentWithActorId, highlightCommentWithActorId].contains(comment.actorId),
                                depthOffset: depthOffset
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1000 - Double(comment.depth))
                            .anchorPreference(
                                key: AnchorsKey.self,
                                value: .center
                            ) { [comment.actorId: $0] }
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: scrollToCommentWithActorId)
                }
                .onAppear {
                    // proxy.scrollTo(scrollToCommentWithActorId, anchor: .center)
                    if let scrollToCommentWithActorId {
                        Task { @MainActor in
                            print(scrollToCommentWithActorId)
                            proxy.scrollTo(scrollToCommentWithActorId, anchor: .center)
                        }
                    }
                    // This is required for some reason, otherwise it occasionally doesn't scroll
//                    Task { @MainActor in
//                        if let scrollToCommentWithActorId {
//                            // The scroll destination isn't always accurate. Possibly due to the post image changing
//                            // size on load? Using `anchor: .top` would be better here, but `anchor: .center` makes
//                            // the inaccuracy less noticeable.
//                            proxy.scrollTo(scrollToCommentWithActorId, anchor: .center)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                self.scrollToCommentWithActorId = nil
//                            }
//                        }
//                    }
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
                if (post.api.fetchedVersion ?? .infinity) >= item.minimumVersion {
                    Label(String(localized: item.label), systemImage: item.systemImage)
                }
            }
        }
    }
}
