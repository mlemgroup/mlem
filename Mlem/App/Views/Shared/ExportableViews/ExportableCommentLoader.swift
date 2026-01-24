//
//  ExportableCommentLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-12-10.
//

import SwiftUI
import MlemMiddleware

/// Class to load and handle data required to display an exportable comment
@Observable
class ExportableCommentLoader {
    var data: ExportableCommentData?
    var error: ErrorDetails?
    
    let rootComment: Comment
    let tracker: CommentTreeTracker?
    
    init(comment: Comment, tracker: CommentTreeTracker?) {
        self.rootComment = comment
        self.tracker = tracker
    }
    
    func load() async {
        do {
            try await rootComment.refresh()
            var comments: [Comment]
            if let tracker {
                await tracker.load(ensuringPresenceOf: rootComment)
                comments = tracker.getThread(preceding: rootComment, limit: 8)
            } else {
                comments = [rootComment]
            }
            
            Task { @MainActor in
                self.data = .init(comments: comments)
            }
        } catch {
            self.error = handleErrorWithDetails(error)
        }
    }
}

struct ExportableCommentData {
    let comments: [Comment]
    
    func thread(length: Int) -> [Comment] {
        comments.suffix(length)
    }
}
