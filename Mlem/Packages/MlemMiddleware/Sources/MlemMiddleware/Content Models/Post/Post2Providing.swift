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
    func updateRead(_ newValue: Bool, shouldQueue: Bool = false) {
        if shouldQueue {
            post2.readQueued = newValue
            Task {
                if newValue {
                    await api.markReadQueue.add(id)
                } else {
                    await api.markReadQueue.remove(id)
                }
            }
        } else {
            post2.readStatus = newValue
            Task {
                await updateQueue.addItem { snapshot in
                    try await self.api.repository.markPostAsRead(id: self.id, read: newValue)
                    if var snapshot2 = snapshot as? Post2Snapshot {
                        snapshot2.read = newValue
                        return snapshot2
                    }
                    if var snapshot3 = snapshot as? Post3Snapshot {
                        snapshot3.post.read = newValue
                        return snapshot3
                    }
                    // this shouldn't ever happen--when Post2Providing is initialized it should set the queue's parent to itself,
                    // so this closure should always receive at least Post2Snapshot
                    assertionFailure("No Post2Snapshot available")
                    return snapshot
                }
            }
        }
    }
    
    /// Update the post when its queued mark read operation completes.
    func queuedMarkReadCompleted() {
        guard post2.readQueued else {
            assertionFailure("readQueueFlushed called but post was not queued")
            return
        }
        // sending this through the updateQueue ensures queue.lastVerifiedSnapshot receives the correct read value
        Task {
            await updateQueue.addItem { snapshot in
                if var snapshot2 = snapshot as? Post2Snapshot {
                    snapshot2.read = true
                    return snapshot2
                }
                if var snapshot3 = snapshot as? Post3Snapshot {
                    snapshot3.post.read = true
                    return snapshot3
                }
                assertionFailure("No Post2Snapshot available")
                return snapshot
            }
            post2.readQueued = false
        }
    }

    func updateVote(_ newValue: ScoringOperation) {
        post2.votes = post2.votes.applyScoringOperation(operation: newValue)
        post2.readStatus = true
        Task {
            await updateQueue.addItem {
                try await self.api.repository.voteOnPost(id: self.id, score: newValue)
            }
        }
    }
    
    func updateSaved(_ newValue: Bool) {
        post2.saved = newValue
        post2.readStatus = true
        Task {
            await updateQueue.addItem {
                return try await self.api.repository.savePost(id: self.id, save: newValue)
            }
        }
    }
    
    func toggleHidden() {
        updateHidden(!hidden)
    }
    
    func updateHidden(_ newValue: Bool) {
        post2.hidden = newValue
        post2.readStatus = true
        Task {
            await updateQueue.addItem { snapshot in
                try await self.api.repository.hidePost(id: self.id, hide: newValue)
                if var snapshot2 = snapshot as? Post2Snapshot {
                    snapshot2.hidden = newValue
                    return snapshot2
                }
                if var snapshot3 = snapshot as? Post3Snapshot {
                    snapshot3.post.hidden = newValue
                    return snapshot3
                }
                assertionFailure("No Post2Snapshot available")
                return snapshot
            }
        }
    }
}

// PersonContentProviding conformance
public extension Post2Providing {
    var userContent: PersonContent { .init(wrappedValue: .post(post2)) }
}
