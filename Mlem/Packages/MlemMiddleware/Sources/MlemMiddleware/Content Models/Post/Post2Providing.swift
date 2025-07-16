//
//  Post2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation
import Nuke

public protocol Post2Providing: Post1Providing, Interactable2Providing, PersonContentProviding, ReadableProviding {
    var post2: Post2 { get }
    
    var creator: any Person { get }
    var community: any Community { get }
    var unreadCommentCount: Int { get }
    var read: Bool { get }
    var hidden: Bool { get }
}

public extension Post2Providing {
    var post1: Post1 { post2.post1 }
    var updateQueue: PostUpdateQueue { post1.updateQueue }
    
    var creator: any Person { post2.creator }
    var community: any Community { post2.community }
    var creatorIsModerator: Bool { post2.creatorIsModerator }
    var creatorIsAdmin: Bool { post2.creatorIsAdmin }
    var creatorBannedFromCommunity: Bool { post2.creatorBannedFromCommunity }
    var commentCount: Int { post2.commentCount }
    var unreadCommentCount: Int { post2.unreadCommentCount }
    var votes: VotesModel { post2.votes }
    var saved: Bool { post2.saved }
    var read: Bool { post2.read }
    var hidden: Bool { post2.hidden }
    
    var creator_: (any Person)? { post2.creator }
    var community_: (any Community)? { post2.community }
    var creatorIsModerator_: Bool? { post2.creatorIsModerator }
    var creatorIsAdmin_: Bool? { post2.creatorIsAdmin }
    var creatorBannedFromCommunity_: Bool? { post2.creatorBannedFromCommunity }
    var commentCount_: Int? { post2.commentCount }
    var unreadCommentCount_: Int? { post2.unreadCommentCount }
    var votes_: VotesModel? { post2.votes }
    var saved_: Bool? { post2.saved }
    var read_: Bool? { post2.read }
    var hidden_: Bool? { post2.hidden }
}

public extension Post2Providing {
    private var votesManager: StateManager<VotesModel> { post2.votesManager }
//    private var readManager: StateManager<Bool> { post2.readManager }
//    private var savedManager: StateManager<Bool> { post2.savedManager }
    private var hiddenManager: StateManager<Bool> { post2.hiddenManager }
        
    func updateRead(_ newValue: Bool, shouldQueue: Bool = false) async throws {
        print("DEBUG updating read to \(newValue)")
        post2.read = newValue
        await updateQueue.addItem {
            try await self.api.repository.markPostAsRead(id: self.id, read: newValue)
            let ret = try await self.api.repository.getPost(id: self.id) // TODO: mock snapshot instead, get real value
            return ret
        }
//        if shouldQueue {
//            return Task { @MainActor in
//                if newValue {
//                    await api.markReadQueue.add(self.id)
//                    post2.updateReadQueued(true)
//                } else {
//                    await api.markReadQueue.remove(self.id)
//                    post2.updateReadQueued(false)
//                }
//                return .deferred
//            }
//        } else {
//            return readManager.performRequest(expectedResult: newValue) { semaphore in
//                try await self.api.markPostAsRead(id: self.id, read: newValue, includeQueuedPosts: true, semaphore: semaphore)
//            }
//        }
    }

    func newUpdateVote(_ newValue: ScoringOperation) throws {
        post2.votes = post2.votes.applyScoringOperation(operation: newValue)
        post2.read = true
        Task {
            await updateQueue.addItem {
                print("DEBUG voting on post")
                return try await self.api.repository.voteOnPost(id: self.id, score: newValue)
            }
        }
//        groupStateRequest(
//            votesManager.ticket(votes.applyScoringOperation(operation: newValue)),
//            readManager.ticket(true)
//        ) { semaphore in
//            try await self.api.voteOnPost(id: self.id, score: newValue, semaphore: semaphore)
//        }
    }
    
    func newUpdateSaved(_ newValue: Bool) throws {
        post2.saved = newValue
        post2.read = true
        Task {
            await updateQueue.addItem {
                print("DEBUG saving post")
                return try await self.api.repository.savePost(id: self.id, save: newValue)
            }
        }
    }
    
    var queuedForMarkAsRead: Bool {
        get async { await api.markReadQueue.ids.contains(id) }
    }
    
    @discardableResult
    func toggleHidden() -> Task<StateUpdateResult, Never> {
        updateHidden(!hidden)
    }
    
    @discardableResult
    func updateHidden(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        // Unlike other post operations, this one does not mark the post as read
        hiddenManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.hidePost(id: self.id, hide: newValue, semaphore: semaphore)
        }
    }
}

// PersonContentProviding conformance
public extension Post2Providing {
    var userContent: PersonContent { .init(wrappedValue: .post(post2)) }
}
