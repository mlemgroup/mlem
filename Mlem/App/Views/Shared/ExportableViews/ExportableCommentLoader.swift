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
    
    let rootComment: any Comment1Providing
    let tracker: CommentTreeTracker?
    
    init(comment: any Comment1Providing, tracker: CommentTreeTracker?) {
        self.rootComment = comment
        self.tracker = tracker
    }
    
    func load() async {
        do {
            guard let comment = try await rootComment.upgrade() as? any Comment2Providing else {
                assertionFailure("Could not cast to Comment2Providing post-upgrade")
                error = .init(error: ApiClientError.unsuccessful)
                return
            }
            
            var comments: [any Comment2Providing]
            if let tracker {
                await tracker.load(ensuringPresenceOf: comment)
                comments = tracker.getThread(preceding: comment, limit: 8)
            } else {
                comments = [comment]
            }
            
            guard let post = try await comment.post.upgrade() as? any Post3Providing else {
                assertionFailure("Could not cast to Post2Providing post-upgrade")
                throw ApiClientError.unsuccessful
            }
            
            Task { @MainActor in
                self.data = .init(comments: comments, post: post)
            }
        } catch {
            self.error = handleErrorWithDetails(error)
        }
    }
}

struct ExportableCommentData {
    let comments: [any Comment2Providing]
    let post: any Post3Providing
    
    func thread(length: Int) -> [any Comment2Providing] {
        comments.suffix(length)
    }
}
