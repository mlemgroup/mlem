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
        .foregroundStyle(palette.secondary)
        .frame(maxWidth: .infinity)
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
                    .quickSwipes(comment.swipeActions(behavior: .standard, commentTreeTracker: tracker))
                    .contextMenu { comment.allMenuActions() }
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
                    MoreRepliesButton(tracker: tracker, comment: comment)
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
            ForEach(ApiCommentSortType.allCases, id: \.self) { item in
                if (post?.api.fetchedVersion ?? .infinity) >= item.minimumVersion {
                    Label(String(localized: item.label), systemImage: item.systemImage)
                }
            }
        }
    }
}
