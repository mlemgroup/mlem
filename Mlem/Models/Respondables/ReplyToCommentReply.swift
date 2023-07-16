//
//  ReplyToCommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct ReplyToCommentReply: Respondable {
    
    var id: Int { commentReply.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let commentReply: APICommentReplyView
    
    func embeddedView() -> AnyView {
        return AnyView(InboxReplyView(reply: commentReply,
                                      menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await postCommentWithoutTracker(postId: commentReply.post.id,
                                            commentId: commentReply.comment.id,
                                            commentContents: responseContents,
                                            account: appState.currentActiveAccount,
                                            appState: appState)
    }
}
