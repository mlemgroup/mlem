//
//  CommentEditor.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-24.
//

import Dependencies
import Foundation
import SwiftUI

struct CommentEditor: ResponseEditorModel {
    @Dependency(\.commentRepository) var commentRepository

    let canUpload: Bool = true
    let showSlurWarning: Bool = true
    let modalName: String = "Edit Comment"
    var prefillContents: String? { comment.comment.content }
    let comment: APICommentView

    let commentTracker: CommentTracker?

    var id: Int { comment.id }

    func embeddedView() -> AnyView {
        AnyView(EmptyView())
    }

    @MainActor
    func sendResponse(responseContents: String) async throws {
        let edited = try await commentRepository.editComment(
            id: comment.id,
            content: responseContents,
            distinguished: nil,
            languageId: nil
        )

        if let commentTracker {
            commentTracker.comments.update(with: edited.commentView)
        }
    }
}
