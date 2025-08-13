//
//  Comment1Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-08-12.
//

extension Comment1Providing {
    public func snapshotUpdate(with snapshot: any CommentSnapshotProviding) {
        
    }
    
    @MainActor
    internal func snapshot1Update(with snapshot: Comment1Snapshot) {
        comment1.setIfChanged(\.content, snapshot.content)
        comment1.setIfChanged(\.updated, snapshot.updated)
        comment1.setIfChanged(\.distinguished, snapshot.distinguished)
        comment1.setIfChanged(\.languageId, snapshot.languageId)
        comment1.setIfChanged(\.deleted, snapshot.deleted)
        comment1.setIfChanged(\.removed, snapshot.removed)
    }
}
