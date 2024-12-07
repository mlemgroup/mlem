//
//  MoreRepliesButton.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-28.
//

import SwiftUI

struct MoreRepliesButton: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(Palette.self) var palette
    
    let tracker: CommentTreeTracker
    let comment: CommentWrapper
    
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
                CommentBarView(depth: comment.depth + 1)
                HStack {
                    Text("More Replies")
                    Image(systemName: Icons.forward)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .opacity(isLoading ? 0 : 1)
                .overlay {
                    if isLoading {
                        ProgressView()
                    }
                }
                .foregroundStyle(palette.accent)
            }
            .background(
                palette.secondaryGroupedBackground,
                in: .rect(cornerRadius: Constants.main.standardSpacing)
            )
            .paletteBorder(cornerRadius: Constants.main.standardSpacing)
        }
        .padding(.leading, CGFloat(comment.depth + 1 - tracker.proposedDepthOffset) * 10)
        .buttonStyle(.plain)
    }
    
    func loadComments() async throws {
        let comments = try await comment.getChildren(
            sort: tracker.sort,
            includedParentCount: 0,
            page: 1,
            maxDepth: Settings.main.maxCommentDepth,
            limit: 999
        )
        
        // TODO: 0.18.0 deprecation: instead of using `max(by: )`, just take the last item of the array
        // (from 0.19.0 onwards the last item of the array will be the deepest)
        
        guard let maxDepth = comments.max(by: { $0.depth < $1.depth })?.depth else {
            return
        }
        // Do we want this threshold to change depending on screen size? Could be tricky if we load comments
        // and then the user makes the window less wide (e.g. on iPad), in which case we'd need to hide
        // the comments that exceed the new maximum width.
        if maxDepth > 12 {
            var comments = comments
            if let parent = comment.parent {
                comments.prepend(parent.comment2)
            }
            navigation.push(.comment(comment, comments: comments, showViewPostButton: false))
        } else {
            await tracker.insertAdditionalComments(comments: comments)
        }
    }
}
