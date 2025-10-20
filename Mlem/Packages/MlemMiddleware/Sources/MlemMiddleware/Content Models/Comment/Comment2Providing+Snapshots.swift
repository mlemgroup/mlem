//
//  Comment2Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-08-15.
//

extension Comment2Providing {
    public func snapshotUpdate(with snapshot: any CommentSnapshotProviding) async {
        if let comment2Snapshot = snapshot as? Comment2Snapshot {
            await snapshot2Update(with: comment2Snapshot)
        } else if let comment1Snapshot = snapshot as? Comment1Snapshot {
            await comment1.snapshot1Update(with: comment1Snapshot)
        } else {
            assertionFailure("Unrecognized comment snapshot")
        }
    }
    
    @MainActor
    func snapshot2Update(with snapshot: Comment2Snapshot) {
        comment2.setIfChanged(\.votes, snapshot.votes)
        comment2.setIfChanged(\.creatorIsModerator, snapshot.creatorIsModerator)
        comment2.setIfChanged(\.creatorIsAdmin, snapshot.creatorIsAdmin)
        comment1.snapshot1Update(with: snapshot.comment)
    }
    
    public func takeSnapshot() -> any CommentSnapshotProviding {
        takeSnapshot2()
    }
    
    func takeSnapshot2() -> Comment2Snapshot {
        .init(
            comment: comment1.takeSnapshot1(),
            creator: creator.takeSnapshot1(),
            post: post.takeSnapshot1(),
            community: community.takeSnapshot1(),
            commentCount: commentCount,
            creatorIsModerator: creatorIsModerator,
            creatorIsAdmin: creatorIsAdmin,
            creatorBannedFromCommunity: creatorBannedFromCommunity,
            votes: votes,
            saved: saved
        )
    }
}
