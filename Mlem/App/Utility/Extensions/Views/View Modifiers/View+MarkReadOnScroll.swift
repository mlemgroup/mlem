//
//  View+MarkReadOnScroll.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-28.
//

import Foundation
import MlemMiddleware
import SwiftUI

private struct MarkReadOnScroll: ViewModifier {
    @Setting(\.markReadOnScroll) var markReadOnScroll
    @Setting(\.postSize) var postSize
    
    var index: Int
    var post: any Post2Providing
    var postFeedLoader: CorePostFeedLoader
    @Binding var bottomAppearedItemIndex: Int
    
    func body(content: Content) -> some View {
        content
            .task {
                do {
                    if markReadOnScroll, try await post.api.supports(.batchMarkRead) {
                        bottomAppearedItemIndex = max(index, bottomAppearedItemIndex)
                    }
                } catch {
                    handleError(error)
                }
            }
            .onDisappear {
                if markReadOnScroll, // mark read on scroll enabled
                   index <= (bottomAppearedItemIndex - postSize.markReadOffset) ||
                   index >= (postFeedLoader.items.count - postSize.markReadOffset) { // edge case: end of feed
                    post.updateRead(true, shouldQueue: true)
                }
            }
    }
}

extension View {
    /// Handles mark read on scroll behavior:
    /// - On appear, stages previous posts to be marked read
    /// - On disappear, if this post is staged, marks it as read
    func markReadOnScroll(
        index: Int,
        post: any Post2Providing,
        postFeedLoader: CorePostFeedLoader,
        bottomAppearedItemIndex: Binding<Int>
    ) -> some View {
        modifier(MarkReadOnScroll(
            index: index,
            post: post,
            postFeedLoader: postFeedLoader,
            bottomAppearedItemIndex: bottomAppearedItemIndex
        ))
    }
}
