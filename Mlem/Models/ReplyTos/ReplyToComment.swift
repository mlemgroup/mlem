//
//  ReplyToComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToComment: ReplyTo {
    let comment: APICommentView
    let account: SavedAccount
    let appState: AppState
    let commentTracker: CommentTracker
    
    func embeddedView() -> AnyView {
        return AnyView(CommentBodyView(commentView: comment,
                                       isCollapsed: false,
                                       showPostContext: true,
                                       showCommentCreator: true)
            .padding(.horizontal))
    }
    
    func sendReply(commentContents: String) async throws {
        guard let account = appState.currentActiveAccount else {
            print("Cannot Submit, No Active Account")
            return
        }
        
        try await postComment(to: comment.id,
                              postId: comment.post.id,
                              commentContents: commentContents,
                              commentTracker: commentTracker,
                              account: account)
    }
}
