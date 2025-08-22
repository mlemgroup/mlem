//
//  Comment1Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-08-12.
//

extension Comment1Providing {
    public func snapshotUpdate(with snapshot: any CommentSnapshotProviding) async {
        if let comment2Snapshot = snapshot as? Comment2Snapshot {
            await snapshot1Update(with: comment2Snapshot.comment)
        } else if let comment1Snapshot = snapshot as? Comment1Snapshot {
            await snapshotUpdate(with: comment1Snapshot)
        } else {
            assertionFailure("Unrecognized comment snapshot")
        }
    }
    
    @MainActor
    internal func snapshot1Update(with snapshot: Comment1Snapshot) {
        // If the comment is removed, the API returns an empty string for the `comment/list` endpoint, but returns the comment content
        // in the modlog endpoint. This `if` statement prevents the comment content being overwritten with that empty string.
        if !snapshot.removed {
            comment1.setIfChanged(\.content, snapshot.content)
        }
        comment1.setIfChanged(\.updated, snapshot.updated)
        comment1.setIfChanged(\.distinguished, snapshot.distinguished)
        comment1.setIfChanged(\.languageId, snapshot.languageId)
        comment1.setIfChanged(\.deleted, snapshot.deleted)
        comment1.setIfChanged(\.removed, snapshot.removed)
    }
    
    public func takeSnapshot() -> any CommentSnapshotProviding {
        takeSnapshot1()
    }
    
    public func takeSnapshot1() -> Comment1Snapshot {
        return Comment1Snapshot(
            actorId: actorId,
            id: id,
            creatorId: creatorId,
            postId: postId,
            parentCommentIds: parentCommentIds,
            created: created,
            content: content,
            updated: updated,
            distinguished: distinguished,
            languageId: languageId,
            deleted: deleted,
            removed: removed
        )
    }
}
