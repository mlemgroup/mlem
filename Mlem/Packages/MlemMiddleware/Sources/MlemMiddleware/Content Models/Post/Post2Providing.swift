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

// snapshot methods
extension Post2Providing {
    public func snapshotUpdate(with snapshot: any PostSnapshotProviding) {
        if let post3snapshot = snapshot as? Post3Snapshot {
            snapshot2Update(with: post3snapshot.post)
        } else if let post2snapshot = snapshot as? Post2Snapshot {
            snapshot2Update(with: post2snapshot)
        } else if let post1snapshot = snapshot as? Post1Snapshot {
            post1.snapshotUpdate(with: post1snapshot)
        } else {
            assertionFailure("Unrecognized post snapshot")
        }
    }
    
    internal func snapshot2Update(with snapshot: Post2Snapshot) {
        post2.commentCount = snapshot.commentCount
        post2.unreadCommentCount = snapshot.unreadCommentCount
        post2.creatorIsModerator = snapshot.creatorIsModerator
        post2.creatorIsAdmin = snapshot.creatorIsAdmin
//        self.creatorBannedFromCommunity = snapshot.creatorBannedFromCommunity
//        self.creatorBlocked = snapshot.creatorBlocked
        post2.votes = snapshot.votes
        post2.saved = snapshot.saved
        post2.read_ = snapshot.read
        post2.hidden = snapshot.hidden
        post2.post1.snapshot1Update(with: snapshot.post)
    }
    
    public func takeSnapshot() -> any PostSnapshotProviding {
        takeSnapshot2()
    }
    
    internal func takeSnapshot2() -> Post2Snapshot {
        .init(post: post1.takeSnapshot1(),
              creator: creator.takeSnapshot1(),
              community: community.takeSnapshot1(),
              commentCount: commentCount,
              unreadCommentCount: unreadCommentCount,
              creatorIsModerator: creatorIsModerator,
              creatorIsAdmin: creatorIsAdmin,
              creatorBannedFromCommunity: creatorBannedFromCommunity,
              creatorBlocked: creator.blocked,
              votes: votes,
              saved: saved,
              read: read, // TODO: NOW point to internal read
              hidden: hidden
        )
    }
}

public extension Post2Providing {
    func updateRead(_ newValue: Bool, shouldQueue: Bool = false) throws {
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
            post2.read_ = newValue
            Task {
                await updateQueue.addItem {
                    try await self.api.repository.markPostAsRead(id: self.id, read: newValue)
                    return try await self.api.repository.getPost(id: self.id) // TODO: mock snapshot instead
                }
            }
        }
    }

    func updateVote(_ newValue: ScoringOperation) throws {
        post2.votes = post2.votes.applyScoringOperation(operation: newValue)
        post2.read_ = true
        Task {
            await updateQueue.addItem {
                return try await self.api.repository.voteOnPost(id: self.id, score: newValue)
            }
        }
    }
    
    func updateSaved(_ newValue: Bool) throws {
        post2.saved = newValue
        post2.read_ = true
        Task {
            await updateQueue.addItem {
                return try await self.api.repository.savePost(id: self.id, save: newValue)
            }
        }
    }
    
    func toggleHidden() throws {
        try updateHidden(!hidden)
    }
    
    func updateHidden(_ newValue: Bool) throws {
        post2.hidden = newValue
        post2.read_ = true
        Task {
            await updateQueue.addItem {
                try await self.api.repository.hidePost(id: self.id, hide: newValue)
                return try await self.api.repository.getPost(id: self.id) // TODO: mock snapshot instead
            }
        }
    }
}

// PersonContentProviding conformance
public extension Post2Providing {
    var userContent: PersonContent { .init(wrappedValue: .post(post2)) }
}
