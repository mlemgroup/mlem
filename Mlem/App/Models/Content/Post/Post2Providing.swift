//
//  Post2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol Post2Providing: Interactable2Providing, Post1Providing {
    var post2: Post2 { get }
    
    var creator: Person1 { get }
    var community: Community1 { get }

    var unreadCommentCount: Int { get }
}

extension Post2Providing {
    var post1: Post1 { post2.post1 }
    var interactable1: Post1 { post1 }
    
    var creator: Person1 { post2.creator }
    var community: Community1 { post2.community }
    var commentCount: Int { post2.commentCount }
    var votes: VotesModel { post2.votes }
    var unreadCommentCount: Int { post2.unreadCommentCount }
    var isSaved: Bool { post2.isSaved }
    var isRead: Bool { post2.isRead }
    
    var creator_: Person1? { post2.creator }
    var community_: Community1? { post2.community }
    var commentCount_: Int? { post2.commentCount }
    var votes_: VotesModel { post2.votes }
    var unreadCommentCount_: Int? { post2.unreadCommentCount }
    var isSaved_: Bool? { post2.isSaved }
    var isRead_: Bool? { post2.isRead }
}

extension Post2Providing {
    private var votesManager: StateManager<VotesModel> { post2.votesManager }
    private var isReadManager: StateManager<Bool> { post2.isReadManager }
    private var isSavedManager: StateManager<Bool> { post2.isSavedManager }

    func vote(_ newVote: ScoringOperation) {
        guard newVote != self.votes.myVote else { return }
        groupStateRequest(
            votesManager.ticket(self.votes.applyScoringOperation(operation: newVote)),
            isReadManager.ticket(true)
        ) { semaphore in
            try await self.api.voteOnPost(id: self.id, score: newVote, semaphore: semaphore)
        }
    }
    
    func toggleSave() {
        let newValue = !isSaved
        if newValue, UserDefaults.standard.bool(forKey: "upvoteOnSave") {
            vote(.upvote)
        }
        groupStateRequest(
            isSavedManager.ticket(newValue),
            isReadManager.ticket(true)
        ) { semaphore in
            try await self.api.savePost(id: self.id, save: newValue, semaphore: semaphore)
        }
    }
}
