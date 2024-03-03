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
    var votes: VotesModel { get { post2.votes } set { post2.votes = newValue } }
    var unreadCommentCount: Int { post2.unreadCommentCount }
    var isSaved: Bool { post2.isSaved }
    var isRead: Bool { get { post2.isRead } set { post2.isRead = newValue } }
    var voteStatusManager: VoteStatusManager { post2.voteStatusManager }
    
    var creator_: Person1? { post2.creator }
    var community_: Community1? { post2.community }
    var commentCount_: Int? { post2.commentCount }
    var votes_: VotesModel { get { post2.votes } set { post2.votes = newValue } }
    var unreadCommentCount_: Int? { post2.unreadCommentCount }
    var isSaved_: Bool? { post2.isSaved }
    var isRead_: Bool? { post2.isRead }
    var voteStatusManager_: VoteStatusManager { post2.voteStatusManager }
  
    func vote(_ newVote: ScoringOperation) {
        // notify the status manager that we are voting now
        let semaphore = voteStatusManager.beginVotingOperation(with: votes)
        
        // state fake
        RunLoop.main.perform {
            self.votes = self.votes.applyScoringOperation(operation: newVote)
        }
        
        Task {
            sleep(5)
            
            do {
                try await api.voteOnPost(id: id, score: newVote, semaphore: semaphore)
            } catch {
                print("DEBUG [\(semaphore)] failed!")
                if let newVotes = voteStatusManager.getRollbackState(semaphore: semaphore) {
                    votes = newVotes
                }
            }
        }
    }
}
