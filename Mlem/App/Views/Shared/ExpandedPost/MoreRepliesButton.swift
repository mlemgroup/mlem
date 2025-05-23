//
//  MoreRepliesButton.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-28.
//

import SwiftUI

struct MoreRepliesButton: View {
    @Environment(NavigationLayer.self) var navigation
    
    let tracker: CommentTreeTracker
    let commentTreeNode: CommentTreeNode
    
    @State var isLoading: Bool = false
    
    var body: some View {
        Button {
            isLoading = true
            Task { @MainActor in
                do {
                    try await loadComments()
                } catch {
                    handleError(error)
                }
                isLoading = false
            }
        } label: {
            HStack {
                CommentBarView(depth: commentTreeNode.comment.depth + 1)
                HStack {
                    Text("More Replies")
                    Image(icon: .general.forward)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .opacity(isLoading ? 0 : 1)
                .overlay {
                    if isLoading {
                        ProgressView()
                    }
                }
                .foregroundStyle(.themedAccent)
            }
            .background(
                .themedSecondaryGroupedBackground,
                in: .rect(cornerRadius: Constants.main.standardSpacing)
            )
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
        .padding(.leading, CGFloat(commentTreeNode.comment.depth + 1 - tracker.proposedDepthOffset) * 10)
        .buttonStyle(.plain)
    }
    
    func loadComments() async throws {
        let comments = try await commentTreeNode.comment.getChildren(
            sort: tracker.sort,
            includedParentCount: 0,
            page: 1,
            maxDepth: Settings.get(\.comment_maxDepth),
            limit: 999
        )
        
        guard let maxDepth = comments.last?.depth else { return }
        
        // Do we want this threshold to change depending on screen size? Could be tricky if we load comments
        // and then the user makes the window less wide (e.g. on iPad), in which case we'd need to hide
        // the comments that exceed the new maximum width.
        if maxDepth > 12 {
            var comments = comments
            if let parent = commentTreeNode.parent {
                comments.prepend(parent.comment)
            }
            navigation.push(.comment(commentTreeNode.comment, comments: comments, showViewPostButton: false))
        } else {
            await tracker.insertAdditionalComments(comments: comments)
        }
    }
}
