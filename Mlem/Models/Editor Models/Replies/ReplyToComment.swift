//
//  ReplyToComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import Dependencies
import SwiftUI

struct ReplyToComment: EditorModel {
    
    @Dependency(\.commentRepository) var commentRepository
    
    var id: Int { comment.id }
    let appState: AppState
    let canUpload: Bool = true
    let modalName: String = "New Comment"
    let prefillContents: String? = nil
    let comment: APICommentView
    let prefillContents: String?
    let commentTracker: CommentTracker?
    
    init(appState: AppState,
         comment: APICommentView,
         prefillContents: String? = nil,
         commentTracker: CommentTracker? = nil) {
        self.appState = appState
        self.comment = comment
        self.prefillContents = prefillContents
        self.commentTracker = commentTracker
    }
    
    func embeddedView() -> AnyView {
        return AnyView(CommentBodyView(commentView: comment,
                                       isCollapsed: false,
                                       showPostContext: true,
                                       showCommentCreator: true,
                                       menuFunctions: [])
            .padding(.horizontal))
    }
    
    func sendResponse(responseContents: String) async throws {
        let postedComment = try await commentRepository.postComment(
            content: responseContents,
            parentId: comment.id,
            postId: comment.post.id
        )
        
        if let commentTracker {
            await MainActor.run {
                withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5)) {
                    // the return value from `.update(with: ...)` is discardable by design but
                    // the `withAnimation` closure implicitly returns it resulting in a warning for an unused
                    // value, the `_` is there to silence this as it's expected
                    _ = commentTracker.comments.update(with: postedComment.commentView)
                }
            }
        }
    }
}
