//
//  ReportCommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-14.
//

import Dependencies
import Foundation
import SwiftUI

struct ReportCommentReply: ResponseEditorModel {
    @Dependency(\.commentRepository) var commentRepository
    
    var id: Int { commentReply.id }
    let canUpload: Bool = false
    let modalName: String = "Report Comment"
    let prefillContents: String? = nil
    let commentReply: ReplyModel
    
    func embeddedView() -> AnyView {
        AnyView(InboxReplyView(reply: commentReply)
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await commentRepository.reportComment(
            id: commentReply.commentReply.commentId,
            reason: responseContents
        )
    }
}
