//
//  ReportComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-15.
//

import Dependencies
import Foundation
import SwiftUI

struct ReportComment: ResponseEditorModel {
    
    @Dependency(\.commentRepository) var commentRepository
    
    var id: Int { comment.hashValue }
    let appState: AppState
    let canUpload: Bool = false
    let modalName: String = "Report Comment"
    let prefillContents: String? = nil
    let comment: CommentModel
    
    func embeddedView() -> AnyView {
        return AnyView(CommentBodyView(commentView: comment,
                                       isCollapsed: false,
                                       showPostContext: true,
                                       menuFunctions: [])
            .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await commentRepository.reportComment(id: comment.comment.id, reason: responseContents)
    }
}
