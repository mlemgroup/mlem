//
//  ReportComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Foundation
import SwiftUI

struct ReportComment: Respondable {
    
    var id: Int { comment.id }
    let appState: AppState
    let canUpload: Bool = false
    let modalName: String = "Report Comment"
    let comment: APICommentView
    
    func embeddedView() -> AnyView {
        return AnyView(CommentBodyView(commentView: comment,
                                       isCollapsed: false,
                                       showPostContext: true,
                                       showCommentCreator: true,
                                       menuFunctions: [])
            .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        _ = try await reportComment(account: appState.currentActiveAccount, commentId: comment.id, reason: responseContents)
    }
}
