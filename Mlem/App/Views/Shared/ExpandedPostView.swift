//
//  ExpandedPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-12.
//

import Foundation
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
    
    let post: AnyPost
    @State var showCommentWithActorId: URL?
    @State var jumpButtonTarget: URL?
    @State var topVisibleItem: URL?
    
    @State var tracker: ExpandedPostTracker?
    
    var body: some View {
        ContentLoader(model: post) { proxy in
            if let post = proxy.entity, let tracker {
                let showLoadingSymbol = showCommentWithActorId == nil || (self.post.isUpgraded && tracker.loadingState != .loading)
                VStack {
                    if showLoadingSymbol {
                        content(for: post, tracker: tracker)
                            .externalApiWarning(entity: post, isLoading: proxy.isLoading)
                            .transition(.opacity)
                    } else {
                        // We *could* show the post here, but we'd need to scroll down as soon as the comments load.
                        // So, show a ProgressView instead (cleaner UX).
                        ProgressView()
                            .tint(.secondary)
                            .transition(.opacity)
                        // TODO: prefetch post image in an `.onChange` here?
                        // This could alleviate the `scrollTo` inaccuracy mentioned further down,
                        // As the post won't change size if the image is able to load in time.
                        // Theoretically we'd also need to do this with comment images, but
                        // unfortunately we don't have time for that because the comments should be
                        // shown as soon as they load.
                    }
                }
                .animation(.default, value: showLoadingSymbol)
                .task {
                    if post.api == appState.firstApi, tracker.loadingState == .idle {
                        post.markRead()
                        await tracker.load()
                    }
                }
                .toolbar {
                    sortPicker(tracker: tracker)
                    if proxy.isLoading {
                        ProgressView()
                    } else {
                        ToolbarEllipsisMenu(post.menuActions())
                    }
                }
            } else {
                ProgressView()
                    .tint(palette.secondary)
            }
        } upgradeOperation: { model, api in
            try await model.upgrade(api: api, upgradeOperation: nil)
            if let post = model.wrappedValue as? any Post {
                if let tracker {
                    tracker.post = post
                    tracker.loadingState = .idle
                    await tracker.load()
                } else {
                    tracker = .init(post: post)
                }
            }
        }
        .background(palette.background)
        .environment(tracker)
    }
    
    // swiftlint:disable:next function_body_length
    @ViewBuilder func content(for post: any Post1Providing, tracker: ExpandedPostTracker) -> some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                FancyScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        LargePostView(post: post, isExpanded: true)
                            .id(post.actorId)
                            .anchorPreference(
                                key: AnchorsKey.self,
                                value: .center
                            ) { [post.actorId: $0] }
                        Divider()
                        ForEach(tracker.comments.tree(), id: \.actorId) { comment in
                            CommentView(comment: comment, highlight: showCommentWithActorId == comment.actorId)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(1000 - Double(comment.depth))
                                .anchorPreference(
                                    key: AnchorsKey.self,
                                    value: .center
                                ) { [comment.actorId: $0] }
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: showCommentWithActorId)
                }
                .onAppear {
                    if let showCommentWithActorId {
                        // The scroll destination isn't always accurate. Possibly due to the post image changing
                        // size on load? Using `anchor: .top` would be better here, but `anchor: .center` makes
                        // the inaccuracy less noticeable. See also the comment further up the file.
                        proxy.scrollTo(showCommentWithActorId, anchor: .center)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showCommentWithActorId = nil
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
    }
    
    @ViewBuilder
    func sortPicker(tracker: ExpandedPostTracker) -> some View {
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
