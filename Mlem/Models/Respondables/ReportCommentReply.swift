//
//  ReportCommentReply.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-14.
//

import Foundation
import SwiftUI

struct ReportCommentReply: Respondable {
    
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
        _ = try await reportComment(account: appState.currentActiveAccount,
                                    commentId: commentReply.commentReply.commentId,
                                    reason: responseContents)
    }
}
