//
//  UserRemovalWalker.swift
//  Mlem
//
//  Created by Sjmarf on 26/03/2024.
//

import Foundation

struct UserRemovalWalker {
    var postTracker: StandardPostTracker?
    var commentTracker: CommentTracker?
    
    @MainActor
    func remove(
        userId: Int,
        postAction: (_ post: PostModel) -> Void,
        commentAction: (_ comment: HierarchicalComment) -> Void
    ) {
        if let postTracker {
            for post in postTracker.items where post.creator.userId == userId {
                postAction(post)
            }
        }
        if let commentTracker {
            for comment in commentTracker.comments where comment.commentView.comment.creatorId == userId {
                commentAction(comment)
            }
        }
    }
}
