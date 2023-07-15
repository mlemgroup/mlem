//
//  ReplyToCommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import Dependencies
import SwiftUI

struct ReplyToCommentReply: Respondable {

    @Dependency(\.commentRepository) var commentRepository
    
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let commentReply: APICommentReplyView
    
    var id: Int { commentReply.id }
    
    func embeddedView() -> AnyView {
        return AnyView(InboxReplyView(reply: commentReply,
                                      menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        await commentRepository.postComment(
            content: responseContents,
            parentId: commentReply.comment.id,
            postId: commentReply.post.id
        )
    }
}
