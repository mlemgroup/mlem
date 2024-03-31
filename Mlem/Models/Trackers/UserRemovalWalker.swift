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
    var inboxTracker: InboxTracker?
    var votesTracker: VotesTracker?
    
    func modify(
        userId: Int,
        postAction: (_ post: PostModel) -> Void,
        commentAction: (_ comment: HierarchicalComment) -> Void,
        inboxAction: (_ item: AnyInboxItem) -> Void,
        voteAction: (_ vote: inout VoteModel) -> Void
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
        if let inboxTracker {
            for item in inboxTracker.items where item.banStatusCreatorId == userId {
                inboxAction(item)
            }
        }
        if let votesTracker, let index = votesTracker.votes.firstIndex(where: { $0.id == userId }) {
            voteAction(&votesTracker.votes[index])
        }
    }
    
    func purge(userId: Int) {
        if let postTracker {
            for post in postTracker.items where post.creator.userId == userId {
                post.purged = true
            }
        }
        if let commentTracker {
            for comment in commentTracker.comments where comment.commentView.comment.creatorId == userId {
                comment.purged = true
            }
        }
        if let votesTracker, let index = votesTracker.votes.firstIndex(where: { $0.id == userId }) {
            votesTracker.votes.remove(at: index)
        }
    }
}
