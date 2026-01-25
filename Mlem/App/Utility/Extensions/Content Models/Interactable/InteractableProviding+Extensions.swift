//
//  InteractableProviding+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-24.
//

import MlemMiddleware

// Utility extensions for InteractableProviding

extension InteractableProviding {
    @MainActor
    func showReplySheet(commentTreeTracker: CommentTreeTracker? = nil) {
        if let responseContext {
            NavigationModel.main.openSheet(.createComment(responseContext, commentTreeTracker: commentTreeTracker))
        } else {
            handleError(MlemError.navigationError("Cannot open sheet"), silent: true)
        }
    }
    
    private var responseContext: CommentEditorView.Context? {
        if let self = self as? Post { return .post(self) }
        if let self = self as? Comment { return .comment(self) }
        return nil
    }
    
    func contextualFlairs() -> Set<PersonFlair> {
        var output: Set<PersonFlair> = []
        if creatorIsAdmin.value ?? false {
            output.insert(.admin)
        }
        if creatorIsModerator.value ?? false {
            output.insert(.moderator)
        }
        if let comment = self as? Comment {
            if let post = comment.post.value_, comment.creatorId == post.creatorId {
                output.insert(.op)
            }
        }
        return output
    }
}
