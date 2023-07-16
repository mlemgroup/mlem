//
//  ReplyToComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToComment: Respondable {
    var id: Int { comment.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let comment: APICommentView
    
    let commentTracker: CommentTracker?
    
    func embeddedView() -> AnyView {
        return AnyView(CommentBodyView(commentView: comment,
                                       isCollapsed: false,
                                       showPostContext: true,
                                       showCommentCreator: true,
                                       menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        if let commentTracker = commentTracker {
            try await postComment(to: comment.id,
                                  postId: comment.post.id,
                                  commentContents: responseContents,
                                  commentTracker: commentTracker,
                                  account: appState.currentActiveAccount)
        } else {
            try await postCommentWithoutTracker(postId: comment.post.id,
                                                commentId: comment.id,
                                                commentContents: responseContents,
                                                account: appState.currentActiveAccount,
                                                appState: appState)
        }
    }
}
