//
//  CommentPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/09/2024.
//

import MlemMiddleware
import SwiftUI
import Theming

struct CommentPage: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    @Environment(\.dismiss) var dismiss
    
    let comment: Comment
    let initialComments: [Comment]?
    @State var tracker: CommentTreeTracker
    let showViewPostButton: Bool
    let exposeRemovedContent: Bool

    init(
        comment: Comment,
        initialComments: [Comment]?,
        showViewPostButton: Bool = false,
        exposeRemovedContent: Bool = false
    ) {
        self.comment = comment
        self.showViewPostButton = showViewPostButton
        self.initialComments = initialComments
        self.exposeRemovedContent = exposeRemovedContent
        self._tracker = .init(wrappedValue: .init(root: .comment(comment, parentCount: 1)))
    }
    
    var body: some View {
        ExpectedView(comment.post) { post in
            content(post: post)
        }
    }
    
    // swiftlint:disable:next function_body_length
    func content(post: Post) -> some View {
        ExpandedPostView(
            post: post,
            tracker: $tracker,
            scrollTargetedComment: comment
        ) {
            if showViewPostButton || tracker.nodes.first?.comment.depth != 0 {
                HStack(spacing: Constants.main.standardSpacing) {
                    if tracker.nodes.first?.comment.depth != 0 {
                        Button {
                            tracker.root = .comment(comment, parentCount: currentDepth + 1)
                            Task {
                                await tracker.refresh()
                            }
                        } label: {
                            HStack {
                                Text("Show Parent")
                                if tracker.loadingState == .loading {
                                    ProgressView()
                                } else {
                                    Image(systemName: "chevron.up")
                                }
                            }
                            .animation(.easeOut(duration: 0.1), value: tracker.loadingState == .loading)
                        }
                    }
                    if showViewPostButton {
                        Button {
                            navigation.push(.post(post))
                        } label: {
                            HStack {
                                Text("View All")
                                Image(icon: .general.forward)
                            }
                        }
                    }
                }
                .buttonStyle(.capsule)
                .padding(.horizontal, Constants.main.standardSpacing)
            }
        }
        .refreshable {
            _ = await Task { @MainActor in
                await tracker.refresh()
            }.value
        }
        .themedGroupedBackground()
        .onAppear {
            Task {
                await tracker.load()
            }
        }
        .environment(\.exposeRemovedContent, exposeRemovedContent)
    }
    
    var currentDepth: Int {
        switch tracker.root {
        case let .comment(_, currentDepth): currentDepth
        default: 0
        }
    }
}
