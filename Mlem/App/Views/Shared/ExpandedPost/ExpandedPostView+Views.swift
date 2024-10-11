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
