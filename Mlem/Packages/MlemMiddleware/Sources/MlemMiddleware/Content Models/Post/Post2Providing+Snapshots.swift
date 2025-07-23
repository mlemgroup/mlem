//
//  Post2Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-22.
//

extension Post2Providing {
    @MainActor
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
    
    @MainActor
    internal func snapshot2Update(with snapshot: Post2Snapshot) {
        post2.setIfChanged(\.commentCount, snapshot.commentCount)
        post2.setIfChanged(\.unreadCommentCount, snapshot.unreadCommentCount)
        post2.setIfChanged(\.creatorIsModerator, snapshot.creatorIsModerator)
        post2.setIfChanged(\.creatorIsAdmin, snapshot.creatorIsAdmin)
        post2.setIfChanged(\.votes, snapshot.votes)
        post2.setIfChanged(\.saved, snapshot.saved)
        post2.setIfChanged(\.readStatus, snapshot.read)
        post2.setIfChanged(\.hidden, snapshot.hidden)
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
              read: post2.readStatus,
              hidden: hidden
        )
    }
}
