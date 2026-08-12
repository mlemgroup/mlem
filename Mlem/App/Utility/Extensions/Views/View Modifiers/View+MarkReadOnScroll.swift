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
    @Setting(\.feed_markReadOnScroll) var markReadOnScroll
    @Setting(\.post_size) var postSize
    
    var index: Int
    var post: Post
    var postFeedLoader: CorePostFeedLoader
    @Binding var bottomAppearedItemIndex: Int
    
    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: Bool.self) { geometry in
                geometry.frame(in: .global).maxY < 90
            } action: { wasAboveTop, isAboveTop in
                if markReadOnScroll, !wasAboveTop, isAboveTop {
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
        post: Post,
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
