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
    internal func snapshot2Update(with snapshot: Comment2Snapshot) {
        comment2.setIfChanged(\.creatorIsModerator, snapshot.creatorIsModerator)
        comment2.setIfChanged(\.creatorIsAdmin, snapshot.creatorIsAdmin)
        comment1.snapshot1Update(with: snapshot.comment)
    }
}
