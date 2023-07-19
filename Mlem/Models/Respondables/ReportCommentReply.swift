//
//  ReportCommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-14.
//

import Dependencies
import Foundation
import SwiftUI

struct ReportCommentReply: Respondable {
    
    @Dependency(\.commentRepository) var commentRepository
    
    var id: Int { commentReply.id }
    let appState: AppState
    let canUpload: Bool = false
    let modalName: String = "Report Comment"
    let commentReply: APICommentReplyView
    
    func embeddedView() -> AnyView {
        return AnyView(InboxReplyView(reply: commentReply,
                                      menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await commentRepository.reportComment(
            id: commentReply.commentReply.commentId,
            reason: responseContents
        )
    }
}
