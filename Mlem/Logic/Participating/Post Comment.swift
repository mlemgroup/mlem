//
//  Post Comment.swift
//  Mlem
//
//  Created by David Bureš on 20.05.2023.
//

import Foundation
import SwiftUI

@MainActor
func postComment(
    to post: APIPostView,
    commentContents: String,
    commentTracker: CommentTracker,
    account: SavedAccount,
    appState: AppState
) async throws {
    let request = CreateCommentRequest(
        account: account,
        content: commentContents,
        languageId: nil,
        parentId: nil,
        postId: post.post.id
    )

    let response = try await APIClient().perform(request: request)
    let comment = HierarchicalComment(comment: response.commentView, children: [])
    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4)) {
        commentTracker.comments.prepend(comment)
    }
}

@MainActor
func postComment(
    to commentId: Int,
    postId: Int,
    commentContents: String,
    commentTracker: CommentTracker,
    account: SavedAccount
) async throws {
    let dominantLanguage = NSLinguisticTagger.dominantLanguage(for: commentContents)
    let request = CreateCommentRequest(
        account: account,
        content: commentContents,
        // TODO: we should map out all the language options...
        languageId: dominantLanguage == "en" ? 37 : nil,
        parentId: commentId,
        postId: postId
    )

    let response = try await APIClient().perform(request: request)

    withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5)) {
        // the return value from `.update(with: ...)` is discardable by design but
        // the `withAnimation` closure implicitly returns it resulting in a warning for an unused
        // value, the `_` is there to silence this as it's expected
        _ = commentTracker.comments.update(with: response.commentView)
    }
}

// TODO: unify these because parentId can be optionsl
/**
 Used to post a comment where no tracker needs to be updated (e.g., from feed or inbox)
 */
@MainActor
func postCommentWithoutTracker(
    to post: APIPostView,
    commentContents: String,
    account: SavedAccount,
    appState: AppState
) async throws {
    let request = CreateCommentRequest(
        account: account,
        content: commentContents,
        languageId: nil,
        parentId: nil,
        postId: post.post.id
    )

    _ = try await APIClient().perform(request: request)
}

/**
 Used
 */
@MainActor
func postCommentToCommentWithoutTracker(
    to commentId: Int,
    postId: Int,
    commentContents: String,
    account: SavedAccount,
    appState: AppState
) async throws {
    let request = CreateCommentRequest(
        account: account,
        content: commentContents,
        languageId: nil,
        parentId: commentId,
        postId: postId
    )
    
    _ = try await APIClient().perform(request: request)
}
