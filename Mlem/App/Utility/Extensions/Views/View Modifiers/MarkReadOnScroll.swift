//
//  MarkReadOnScroll.swift
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
    
    func body(content: Content) -> some View {
        content
            .task {
                do {
                    if markReadOnScroll, try await post.api.batchMarkReadEnabled {
                        postFeedLoader.stageForMarkRead(before: index, offset: postSize.markReadOffset)
                    }
                } catch {
                    handleError(error)
                }
            }
            .onDisappear {
                if markReadOnScroll {
                    post.markReadIfStaged()
                }
            }
    }
}

extension View {
    /// Handles mark read on scroll behavior:
    /// - On appear, stages previous posts to be marked read
    /// - On disappear, if this post is staged, marks it as read
    func markReadOnScroll(index: Int, post: any Post2Providing, postFeedLoader: CorePostFeedLoader) -> some View {
        modifier(MarkReadOnScroll(index: index, post: post, postFeedLoader: postFeedLoader))
    }
}
