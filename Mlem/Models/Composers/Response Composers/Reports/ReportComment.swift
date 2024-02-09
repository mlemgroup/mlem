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
    
    var id: Int { comment.id }
    let canUpload: Bool = false
    let showSlurWarning: Bool = false
    let modalName: String = "Report Comment"
    let prefillContents: String? = nil
    let comment: APICommentView
    
    func embeddedView() -> AnyView {
        AnyView(CommentBodyView(
            commentView: comment,
            isParentCollapsed: .constant(false),
            isCollapsed: .constant(false),
            showPostContext: true,
            menuFunctions: [],
            links: []
        )
        .padding(.horizontal, AppConstants.postAndCommentSpacing))
    }
    
    func sendResponse(responseContents: String) async throws {
        try await commentRepository.reportComment(id: comment.id, reason: responseContents)
    }
}
