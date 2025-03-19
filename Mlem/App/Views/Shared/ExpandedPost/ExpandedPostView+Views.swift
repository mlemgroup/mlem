//
//  ExpandedPostView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 11/10/2024.
//

import MlemMiddleware
import SwiftUI

extension ExpandedPostView {
    @ViewBuilder
    var noCommentsView: some View {
        VStack(spacing: 5) {
            Image(systemName: Icons.noContent)
                .font(.title)
                .foregroundStyle(.tertiary)
            Text("No comments found")
                .fontWeight(.semibold)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.themedSecondary)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func commentTree(tracker: CommentTreeTracker) -> some View {
        ForEach(generateViewTree(for: tracker.nodes), id: \.hashValue) { item in
            Group {
                switch item {
                case let .comment(node):
                    let comment = node.comment
                    CommentView(
                        comment: comment,
                        treeNode: node,
                        // TODO: This could theoretically fail to highlight the comment if `highlightedComment` is a `CommentStub`
                        // with a non-actorId URL. We should implement additional logic of some sort to handle this.
                        highlight: [scrollTargetedComment?.actorId_, highlightedComment?.actorId_].contains(comment.actorId),
                        depthOffset: tracker.proposedDepthOffset
                    )
                    .quickSwipes(comment.swipeActions(appState: appState, behavior: .standard, commentTreeTracker: tracker))
                    .contextMenu {
                        comment.allMenuActions(appState: appState, navigation: navigation, commentTreeTracker: tracker)
                    }
                    .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000 - Double(comment.depth))
                    .anchorPreference(
                        key: AnchorsKey.self,
                        value: .center
                    ) { [comment.actorId: $0] }
                    .padding(.leading, CGFloat(comment.depth - tracker.proposedDepthOffset) * 10)
                    .id(comment.actorId)
                case let .unloadedComments(comment, _):
                    MoreRepliesButton(tracker: tracker, commentTreeNode: comment)
                }
            }
            .padding(.horizontal, Constants.main.standardSpacing)
            .padding(.top, compactComments ? Constants.main.halfSpacing : Constants.main.standardSpacing)
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
            ForEach(CommentSortType.legacyCases, id: \.self) { item in
                if (post?.api.fetchedVersion ?? .infinity) >= item.minimumVersion {
                    Label(item.label(timeRangeFormat: .topOnly), systemImage: item.systemImage)
                }
            }
        }
    }
}
