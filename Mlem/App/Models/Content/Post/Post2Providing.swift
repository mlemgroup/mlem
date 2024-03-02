//
//  Post2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol Post2Providing: InteractableContent, Post1Providing {
    var post2: Post2 { get }
    
    var creator: Person1 { get }
    var community: Community1 { get }

    var unreadCommentCount: Int { get }
}

extension Post2Providing {
    var post1: Post1 { post2.post1 }
    
    var creator: Person1 { post2.creator }
    var community: Community1 { post2.community }
    var commentCount: Int { post2.commentCount }
    var upvoteCount: Int { get { post2.upvoteCount } set { post2.upvoteCount = newValue } }
    var downvoteCount: Int { get { post2.downvoteCount } set { post2.downvoteCount = newValue } }
    var unreadCommentCount: Int { post2.unreadCommentCount }
    var isSaved: Bool { post2.isSaved }
    var isRead: Bool { get { post2.isRead } set { post2.isRead = newValue } }
    var myVote: ScoringOperation { get { post2.myVote } set { post2.myVote = newValue } }
    
    var creator_: Person1? { post2.creator }
    var community_: Community1? { post2.community }
    var commentCount_: Int? { post2.commentCount }
    var upvoteCount_: Int? { post2.upvoteCount }
    var downvoteCount_: Int? { post2.downvoteCount }
    var unreadCommentCount_: Int? { post2.unreadCommentCount }
    var isSaved_: Bool? { post2.isSaved }
    var isRead_: Bool? { post2.isRead }
    var myVote_: ScoringOperation? { post2.myVote }
    
    var score: Int { upvoteCount - downvoteCount }
    
    func vote(_ newVote: ScoringOperation) {
        if let oldTask = post2.tasks.vote, !oldTask.isCancelled { oldTask.cancel() }
        post2.tasks.vote = Task(priority: .userInitiated) { await voteTask(newVote) }
    }

    func voteTask(_ newVote: ScoringOperation) async {
        if newVote == myVote { return }

        let oldVote = myVote
        let oldUpvoteCount = upvoteCount
        let oldDownvoteCount = downvoteCount
        let oldReadStatus = isRead

        DispatchQueue.main.async {
            self.upvoteCount += newVote.upvoteValue - oldVote.upvoteValue
            self.downvoteCount += newVote.downvoteValue - oldVote.downvoteValue
            self.myVote = newVote
            self.isRead = true
        }

        do {
            let response = try await api.voteOnPost(id: id, score: newVote)
            // TODO: necessary? Seems to be working without this O_o
//            if !Task.isCancelled {
//                DispatchQueue.main.async {
//                    self.post2.update(with: response.postView, excludeActions: true)
//                    self.post2.tasks.vote = nil
//                }
//            } else {
//                print("\(newVote) task cancelled (Request)")
//            }
        } catch ApiClientError.cancelled {
            print("\(newVote) task cancelled (APIClient)")
            post2.tasks.vote = nil
        } catch {
            print("\(newVote) task error: \(error)")
            DispatchQueue.main.async {
                self.myVote = oldVote
                self.upvoteCount = oldUpvoteCount
                self.downvoteCount = oldDownvoteCount
                self.isRead = oldReadStatus
            }
            post2.tasks.vote = nil
        }
    }
}
