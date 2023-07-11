//
//  ReplyToCommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToCommentReply: ReplyTo {
    let commentReply: APICommentReplyView
    let appState: AppState
    
    func embeddedView() -> AnyView {
        return AnyView(InboxReplyView(reply: commentReply,
                                      menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendReply(commentContents: String) async throws {
        try await postCommentWithoutTracker(postId: commentReply.post.id,
                                            commentId: commentReply.comment.id,
                                            commentContents: commentContents,
                                            account: appState.currentActiveAccount,
                                            appState: appState)
    }
}
