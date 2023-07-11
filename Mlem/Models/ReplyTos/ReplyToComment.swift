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
                                       showCommentCreator: true,
                                       menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendReply(commentContents: String) async throws {
        try await postComment(to: comment.id,
                              postId: comment.post.id,
                              commentContents: commentContents,
                              commentTracker: commentTracker,
                              account: account)
    }
}
