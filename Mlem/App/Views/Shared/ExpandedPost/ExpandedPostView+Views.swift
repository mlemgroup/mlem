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
            Image(icon: .lemmy.noContent)
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
    func commentTree(tracker: CommentTreeTracker, scrollProxy: ScrollViewProxy) -> some View {
        ForEach(generateViewTree(for: tracker.nodes), id: \.hashValue) { item in
            Group {
                switch item {
                case let .comment(node):
                    nodeView(node: node, depthOffset: tracker.proposedDepthOffset, scrollProxy: scrollProxy)
                case let .unloadedComments(comment, _):
                    MoreRepliesButton(tracker: tracker, commentTreeNode: comment)
                }
            }
            .padding(.horizontal, Constants.main.standardSpacing)
            .padding(.top, compactComments ? Constants.main.halfSpacing : Constants.main.standardSpacing)
        }
    }
    
    @ViewBuilder
    func nodeView(node: CommentTreeNode, depthOffset: Int, scrollProxy: ScrollViewProxy) -> some View {
        let comment = node.comment
        CommentView(
            comment: comment,
            treeNode: node,
            highlight: [scrollTargetedComment?.actorId, highlightedComment?.actorId].contains(comment.actorId),
            depthOffset: depthOffset
        )
        .onTapGesture {
            if tapCommentsToCollapse {
                withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                    node.collapsed.toggle()
                }
            }
        }
        .onChange(of: node.collapsed) { _, isCollapsed in
            guard isCollapsed else { return }
            
            withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                scrollProxy.scrollTo(comment.actorId)
            }
        }
        .quickSwipes(comment: comment, configuration: commentInteractionBar)
        .contextMenu {
            comment.allMenuActions(appState: appState, navigation: navigation, commentTreeTracker: tracker)
        }
        .popupAnchor()
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1000 - Double(comment.depth))
        .anchorPreference(
            key: AnchorsKey.self,
            value: .center
        ) { [comment.actorId: $0] }
        .padding(.leading, CGFloat(comment.depth - depthOffset) * 10)
        .id(comment.actorId)
    }
    
    @ViewBuilder
    func sortPicker(tracker: CommentTreeTracker) -> some View {
        Menu("Sort", icon: tracker.sort.icon) {
            ForEach(CommentSortType.legacyCases, id: \.self) { item in
                if post.api.supports(.commentSortType(item), defaultValue: true) {
                    Toggle(
                        item.label(timeRangeFormat: .topOnly),
                        icon: item.icon,
                        isOn: .init(
                            get: { tracker.sort == item },
                            set: { _ in
                                tracker.sort = item
                                tracker.clear()
                                Task { await tracker.load() }
                            }
                        )
                    )
                }
            }
        }
    }
}
